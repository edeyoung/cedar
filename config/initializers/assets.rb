# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

# Adding to pre-compile assets, per http://stackoverflow.com/questions/22970573/asset-filtered-out-and-will-not-be-served-add-config-assets-precompile
Rails.application.config.assets.precompile += [
  /.*\.js/,
  /.*\.css/,
  /.*\.woff/,
  /.*\.woff2/,
  /.*\.eot/,
  /.*\.svg/,
  /.*\.ttf/
]
