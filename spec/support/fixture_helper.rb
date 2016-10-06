module FixtureHelper
  def setup
    Settings[:ignore_roles] = false
    collection_fixtures('product_tests', 'products', 'bundles', 'artifacts',
                        'measures', 'records', 'patient_cache',
                        'health_data_standards_svs_value_sets')
    # collection_fixtures('measures', 'health_data_standards_svs_value_sets')
    puts 'Setup called'
    load_library_functions
  end

  def teardown
    drop_database
  end

  def create_rack_test_file(filename, type)
    Rack::Test::UploadedFile.new(File.new(File.join(Rails.root, filename)), type)
  end

  def drop_database
    Mongoid::Config.purge!
    # purge the database instead of dropping it
    # because dropping it literally deletes the file
    # which then has to be recreated (which is slow)
  end

  def drop_collection(collection)
    Mongoid.default_client[collection].drop
  end

  def arrays_equivalent(a1, a2)
    return true if a1 == a2
    return false unless a1 && a2 # either one is nil
    a1.count == a2.count && (a1 - a2).empty? && (a2 - a1).empty?
  end

  def value_or_bson(v)
    if v.is_a? Hash
      if v['$oid']
        BSON::ObjectId.from_string(v['$oid'])
      else
        map_bson_ids(v)
      end
    else
      v
    end
  end

  def map_array(arr)
    ret = []
    arr.each do |v|
      ret << value_or_bson(v)
    end
    ret
  end

  def map_bson_ids(json)
    json.each_pair do |k, v|
      if v.is_a? Hash
        json[k] = value_or_bson(v)
      elsif v.is_a? Array
        json[k] = map_array(v)
      elsif k == 'create_at' || k == 'updated_at'
        json[k] = Time.at.local(v).in_time_zone
      end
    end
    json
  end

  def collection_fixtures(*collections)
    collections.each do |collection|
      Mongoid.default_client[collection].drop
      Dir.glob(File.join(Rails.root, 'spec', 'fixtures', collection, '*.json')).each do |json_fixture_file|
        puts 'Importing-----------' + json_fixture_file
        fixture_json = JSON.parse(File.read(json_fixture_file), max_nesting: 250)
        map_bson_ids(fixture_json)
        Mongoid.default_client[collection].insert_one(fixture_json)
      end
    end
  end

  def load_library_functions
    Dir.glob(File.join(Rails.root, 'spec', 'fixtures', 'library_functions', '*.js')).each do |js_path|
      puts 'Importing functions-----------' + js_path
      fn = "function () {\n #{File.read(js_path)} \n }"
      name = File.basename(js_path, '.js')
      Mongoid.default_client['system.js'].replace_one({ '_id' => name },
                                                      { '_id' => name,
                                                        'value' => BSON::Code.new(fn)
                                                       }, upsert: true
                                                      )
    end
  end
end
