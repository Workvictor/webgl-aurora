const TerserPlugin = require('terser-webpack-plugin');
const CssMinimizerPlugin = require('css-minimizer-webpack-plugin');
const configSource = require('./webpack.config');
const webpack = require('webpack');

const mode = 'production';

const config = configSource[0];

config.module.rules[0].options = {
  transpileOnly: false,
};

const common = {
  mode,
  devtool: undefined,
  stats: {
    ...config.stats,
    modules: true,
  },
};

config.plugins.splice(
  0,
  1,
  new webpack.DefinePlugin({
    DEV_MODE: JSON.stringify(false),
  })
);

const rendererConfig = {
  ...config,
  ...common,
  optimization: {
    minimize: true,
    minimizer: [
      new TerserPlugin({
        terserOptions: {
          compress: {
            passes: 3,
            drop_console: true,
            ecma: 8,
          },
          mangle: {
            properties: {
              // keep_quoted: true,
              regex: /^\$\w+/,
            },
          },
          ecma: 8,
          module: true,
        },
      }),
      new CssMinimizerPlugin(),
    ],
  },
};

module.exports = [rendererConfig];
