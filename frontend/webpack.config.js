
const path = require("path");
const webpack = require("webpack");
const Dotenv = require('dotenv-webpack');

module.exports = {
  entry: "./src/index.js",
  output: {
    // Corrected: This is the root directory where all your compiled frontend assets will go.
    // It will be 'frontend/static/frontend/' relative to your 'frontend' directory.
    path: path.resolve(__dirname, "static/frontend/"),
    // This defines the filename for your main JavaScript bundle.
    // It will be placed directly in the output.path (e.g., frontend/static/frontend/main.js)
    filename: "[name].js",
    // This publicPath helps Webpack resolve asset URLs correctly in the final built files.
    // If Django serves your frontend static files from '/static/frontend/', this is the correct public path.
    publicPath: '/static/frontend/',
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: "babel-loader",
          options: {
            presets: ['@babel/preset-env', '@babel/preset-react']
          }
        },
      },
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader']
      },
      {
        test: /\.(png|svg|jpg|jpeg|gif)$/i,
        type: 'asset/resource',
        generator: {
          // Images will be placed in an 'images/' subfolder relative to the output.path.
          // So, they'll be at frontend/static/frontend/images/[name][ext]
          filename: 'images/[name][ext]'
        }
      }
    ],
  },
  optimization: {
    minimize: true,
  },
  plugins: [
    new webpack.DefinePlugin({
      "process.env": {
        // This has effect on the react lib size
        NODE_ENV: JSON.stringify("development"),
      },
    }),
    new Dotenv(),
  ],
};