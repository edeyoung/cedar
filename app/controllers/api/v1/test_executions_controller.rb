module API
  module V1
    class TestExecutionsController < API::V1::BaseController
      include Roar::Rails::ControllerAdditions

      respond_to :json_api

      resource_description do
        short 'Test cases'
        formats ['json']
        header 'X-API-EMAIL', 'user\'s email', required: true
        header 'X-API-TOKEN', 'user\'s current authentication token', required: true
        description <<-EOS
        Test Executions accept a set of measures and validations to create valid and
        invalid qrda data with.
        EOS
      end

      api! 'get all tests of current user'
      def index
        render json: TestExecutionRepresenter.for_collection.new(TestExecution.user(current_user))
      end

      api! 'get test'
      def show
        respond_with TestExecution.user(current_user).find(params[:id])
      end

      api! 'create new test'
      param :data, Hash, desc: 'Root level hash', required: true do
        param :attributes, Hash, desc: 'Properties to set', required: true do
          param :name, String, desc: 'Name of test', required: true
          param :description, String, desc: 'Description for this test'
          param :reporting_period, BUNDLE_MAP.keys, desc: 'Which year measures will be from', required: true
          param :qrda_type, %w(1 3),
                desc: '"1" or "3" for category 1 and category 3 QRDA data, measures, and validations, respectively',
                required: true
          param :validations, Hash,
                desc: 'Validation selection. Validations are referenced individually by their code/id, and collectively through tags.
Cedar will attempt to filter out incompatible validations, and a message will be sent in the meta hash of the response if validations are removed.',
                required: true do
            param :tags, Array, of: String, desc: 'Compatible validations with these tags will be included'
            param :include, Array, of: String, desc: 'Individual validations to include'
            param :exclude, Array, of: String, desc: 'Individual validations to be excluded (applied last)'
            param :all, Boolean, desc: 'Set true to include all compatible validations. Excluded validations are still excluded'
          end
          param :measures, Hash,
                desc: 'Measure selection. Measures are referenced individually by their cms_id or hqmf_id, and collectively through tags.
Cedar will attempt to filter out incompatible measures, and a message will be sent in the meta hash of the response if measures are removed.',
                required: true do
            param :tags, Array, of: String, desc: 'Compatible measures with these tags will be included'
            param :include, Array, of: String, desc: 'Individual measures to include'
            param :exclude, Array, of: String, desc: 'Individual measures to be excluded (applied last)'
            param :all, Boolean, desc: 'Set true to include all compatible measures. Excluded measures are still excluded'
          end
        end
      end
      def create
        te = TestExecution.new
        # NOTE: Roar makes #consume! available, that is supposed to make this much easier
        # However, it does not play nice with controller tests and apipie example generation
        # Also, from_hash(params) would not work with application/vnd.api+json content-type if not for code in initializers/mime_types.rb
        TestExecutionRepresenter.new(te).from_hash(params)

        # Measures and validations need to be processed separately and after everything else
        process_measure_params(te)
        process_validation_params(te)

        # Check for conflicts in settings, and try to salvage
        @errors = []
        @warnings = []
        validate_test_execution(te)

        hash = {}
        if @warnings.any?
          hash['meta'] = {}
          hash['meta']['filtered'] = @warnings
        end
        if @errors.any?
          te.destroy
          hash[:errors] = @errors
          render json: hash, status: 400
        else
          current_user.test_executions << te
          CreateDocumentsJob.perform_later(te)
          hash.merge! TestExecutionRepresenter.new(te).to_hash
          render json: hash, status: 202
        end
      end

      api! 'delete test'
      def destroy
        TestExecution.find(params[:id]).destroy
        render json: { message: 'Test execution deleted.' }, success: true, status: 200
      end

      private

      def process_measure_params(te)
        m_params = params[:data][:attributes][:measures]
        filtered = Measure.all.bundle_id(te.bundle.id).top_level.to_a
        te.measures = process_tag_include_exclude_options(filtered, m_params) { |ids| convert_measures ids }
      end

      def process_validation_params(te)
        v_params = params[:data][:attributes][:validations]
        filtered = te.determine_useful_validations
        te.validations = process_tag_include_exclude_options(filtered, v_params) { |ids| convert_validations ids }
      end

      # For validation and measure selection.
      # all is a filtered array of validation/measure
      # options is the params hash
      # yields a block to convert measure/validation from input ids to actual validation/measure object
      def process_tag_include_exclude_options(all, options)
        included = []

        included = all if options[:all]
        included.concat(all.select { |item| (item.tags & options[:tags]).any? }) if options[:tags]
        included.concat(yield(options[:include])) if options[:include]
        if options[:exclude]
          excluded = yield(options[:exclude])
          included -= excluded
        end
        included
      end

      def validate_test_execution(test_execution)
        check_measure_year(test_execution)
        check_validation_qrda_type(test_execution)
        check_validation_measure_type(test_execution)
        check_nulls(test_execution)
      end

      def check_measure_year(test_execution)
        # Makes sure all measures are in the reporting year chosen
        bundle_id = test_execution.bundle.id
        invalid_measures = test_execution.measures.select { |measure| measure.bundle_id != bundle_id }

        if invalid_measures.any?
          test_execution.measures -= invalid_measures
          @warnings << {
            removed: invalid_measures.map(&:cms_id).join(', '),
            reason: 'Incorrect Measure Reporting Period',
            conflict: test_execution.reporting_period.to_s
          }
        end
      end

      def check_validation_measure_type(test_execution)
        # Checks that if there's only one category of measure chosen, all validations work with that type
        measure_types = test_execution.selected_measure_types
        if !measure_types[:discrete]
          invalid = 'discrete'
          valid = 'continuous'
        elsif !measure_types[:continuous]
          invalid = 'continuous'
          valid = 'discrete'
        else
          return
        end
        invalid_validation_ids = test_execution.validations.select { |validation| validation.measure_type == invalid }.map(&:code)
        if invalid_validation_ids.any?
          @errors << {
            title: 'Incompatible Validations and Measures',
            detail: "All selected measures are #{valid}, but validations #{invalid_validation_ids.join(',')} are only for #{invalid} measures"
          }
        end
      end

      def check_validation_qrda_type(test_execution)
        # Makes sure all validations are of the chosen qrda type
        qrda_type = test_execution.qrda_type
        invalid_validations = test_execution.validations.select { |validation| validation.qrda_type != 'all' && validation.qrda_type != qrda_type }
        if invalid_validations.any?
          test_execution.validations -= invalid_validations
          @warnings << {
            removed: invalid_validations.map(&:code).join(', '),
            reason: 'Incorrect QRDA Type',
            conflict: "QRDA cat #{qrda_type}"
          }
        end
      end

      def check_nulls(test_execution)
        # Will not continue with creation if there are no validations or measures
        if test_execution.validations.empty?
          @errors << {
            title: 'No Validations',
            detail: 'Either no validations were chosen, or all were automatically removed because of conflicts. Check /meta/filtered'
          }
        end
        if test_execution.measures.empty?
          @errors << {
            title: 'No Measures',
            detail: 'Either no measures were chosen, or all were automatically removed. Check /meta/filtered'
          }
        end
      end

      # The convert functions take arrays of human readable ids and convert them into measure/validation objects
      def convert_measures(hqmf_or_cms_ids)
        Measure.any_of({ :hqmf_id.in => hqmf_or_cms_ids.collect(&:upcase) },
                       :cms_id.in => hqmf_or_cms_ids.collect { |i| /^#{Regexp.escape(i)}$/i }).to_a
      end

      def convert_validations(codes)
        Validation.where(:code.in => codes.collect(&:downcase)).to_a
      end
    end
  end
end
