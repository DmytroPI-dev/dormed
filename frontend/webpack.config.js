import { resolve } from "path";
import { DefinePlugin } from "webpack";
import Dotenv from 'dotenv-webpack';

export const entry = "./src/index.js";

export const output = {
  path: resolve(__dirname, "static/frontend/"),
  filename: "[name].js",
  publicPath: '/static/frontend/',
};

export const resolveConfig = {
  alias: {
    static: resolve(__dirname, "static"), // Now you can do import from "static/..."
  },
  extensions: ['.js', '.jsx', '.json']
};

export const module = {
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
        filename: 'images/[name][ext]'
      }
    }
  ],
};

export const optimization = {
  minimize: true,
};

export const plugins = [
  new DefinePlugin({
    "process.env": {
      NODE_ENV: JSON.stringify("development"),
    },
  }),
  new Dotenv(),
];
