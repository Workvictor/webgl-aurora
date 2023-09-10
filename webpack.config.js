const HtmlWebpackPlugin = require('html-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const path = require('path');
const webpack = require('webpack');

const devtool = 'inline-source-map';

const tsLoader = {
  test: /\.(ts|tsx)$/,
  loader: 'ts-loader',
  options: { transpileOnly: true },
  exclude: '/node_modules/',
};

const filename = '[name].js';

const extensions = ['.js', '.ts', '.tsx', '.css'];

const stats = {
  modules: false,
  reasons: false,
  moduleTrace: false,
  entrypoints: false,
};

const rendererConfig = {
  target: ['web'],
  mode: 'development',
  devtool,
  entry: {
    index: {
      import: './src/index.ts',
      filename,
    },
  },
  plugins: [
		new webpack.DefinePlugin({
			DEV_MODE: JSON.stringify(true),
		}),
    new MiniCssExtractPlugin(),
    new HtmlWebpackPlugin({
      template: './src/index.html',
    }),
  ],
  module: {
    rules: [
      tsLoader,
      {
        test: /\.css$/,
        use: [
          {
            loader: MiniCssExtractPlugin.loader,
          },
          'css-loader',
        ],
      },
      {
        test: /\.(glsl)$/,
        type: 'asset/resource',
        generator: {
          filename: 'data/[hash:4][ext]',
        },
        exclude: [path.resolve(__dirname, 'src/index.html')],
      },
    ],
  },
  resolve: {
    extensions,
    alias: {
      src: path.resolve(__dirname, './src/'),
    },
  },
  stats,
};

module.exports = [rendererConfig];
