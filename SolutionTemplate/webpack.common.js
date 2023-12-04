const webpack = require('webpack');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const glob = require("glob");
const _ = require('lodash');
const Path = require('path');
const TerserPlugin = require("terser-webpack-plugin");


module.exports = {
    // Add entry point for each entity to be compiled.
    entry: Object.assign({},
        _.reduce(glob.sync("./WebResources/src/ts/**/*.ts"),
            (obj, val) => {
                const filenameRegex = /([\w\d_-]*)\.?[^\\\/]*$/i;
                obj[val.match(filenameRegex)[1]] = val;
                return obj;
            },
            {})
    ),
    output: {
        clean: true,
        filename: "[name].js",
        path: __dirname + "/dist",
        library: 'AddName_[name]'
    },
    resolve: {
        // Add '.ts' and '.tsx' as resolvable extensions.
        extensions: [".ts", ".tsx", ".js", ".json"]
    },

    optimization: {
        minimizer: [
          new TerserPlugin({
            terserOptions: {
              compress: {
                drop_console: true
              }
            }
          })
        ]
      },

    module: {
        rules: [
            {
                test: /\.tsx?$/,
                exclude: /node_modules/,
                use: [{
                    loader: 'ts-loader'
                }]
            },
            { test: /\.js$/, use: ["source-map-loader"], enforce: "pre" },
            {
                test: require.resolve("./WebResources/src/library/dg.xrmquery.web.min"),
                loader: "exports-loader",
                options: {
                    exports: ["XrmQuery", "Filter", "XQW"]
                }
            }
        ]
    },
    plugins: [
        new CopyWebpackPlugin([
            { from: 'WebResources/src/css', to: 'css' },
            { from: 'WebResources/src/html', to: 'html' },
            { from: 'WebResources/src/images', to: 'images' },
            { from: 'WebResources/src/library', to: 'library' }
        ]),
        new webpack.ProvidePlugin({
            XrmQuery: [Path.resolve(__dirname, "./WebResources/src/library/dg.xrmquery.web.min"), "XrmQuery"],
            Filter: [Path.resolve(__dirname, "./WebResources/src/library/dg.xrmquery.web.min"), "Filter"],
            XQW: [Path.resolve(__dirname, "./WebResources/src/library/dg.xrmquery.web.min"), "XQW"],
        })
    ]
};