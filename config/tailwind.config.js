/** @type {import('tailwindcss').Config} */
module.exports = {
    content: [
      './public/*.html',
      './app/helpers/**/*.rb',
      './app/javascript/**/*.js',
      './app/views/**/*.{erb,haml,html,slim}',
      './app/components/**/*.{erb,haml,html,slim,rb}',
      './app/assets/stylesheets/**/*.css',
    ],
    theme: {
      extend: {},
    },
    plugins: [
      require('@tailwindcss/forms'),
      require('@tailwindcss/aspect-ratio'),
      require('@tailwindcss/typography'),
    ],
  }