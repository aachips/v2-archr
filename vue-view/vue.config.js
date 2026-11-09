module.exports = {
  publicPath: './',
  pages: {
    intake: {
      entry: 'src/intake-app.js',
      template: 'public/intake.html',
      filename: 'intake.html',
      title: 'ARCHR — Apply for Home Repair Assistance',
    },
    portal: {
      entry: 'src/main.js',
      template: 'public/portal.html',
      filename: 'portal.html',
      title: 'ARCHR — Case Portal',
    },
    'volunteer-intake': {
      entry: 'src/volunteer-intake-app.js',
      template: 'public/volunteer-intake.html',
      filename: 'volunteer-intake.html',
      title: 'ARCHR — Apply to Volunteer',
    },
  },
  outputDir: 'dist',
  assetsDir: 'assets',
  devServer: {
    proxy: {
      '/app': {
        target: 'http://127.0.0.1:8080',
        changeOrigin: true,
      },
    },
  },
};
