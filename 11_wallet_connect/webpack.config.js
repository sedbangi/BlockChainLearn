const path = require('path');

module.exports = {
  entry: './src/index.ts', // 入口文件
  output: {
    filename: 'bundle.js',
    path: path.resolve(__dirname, 'src'), // 输出目录
  },
  resolve: {
    extensions: ['.ts', '.js'], // 解析文件类型
  },
  module: {
    rules: [
      {
        test: /\.ts$/, // 匹配 .ts 文件
        use: 'ts-loader', // 使用 ts-loader 处理
        exclude: /node_modules/,
      },
    ],
  },
  mode: 'development', // 开发模式
};