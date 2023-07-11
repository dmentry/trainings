const { environment } = require('@rails/webpacker')

const webpack = require('webpack')

environment.
  plugins.
  append(
    'Provide',
    new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery',
      'jquery-ui': 'jquery-ui-dist/jquery-ui.js',
      Popper: ['popper.js', 'default']
    })
  )

module.exports = environment
