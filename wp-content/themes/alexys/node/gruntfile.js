module.exports = function(grunt) {
    grunt.initConfig({
        copy: [{
                files: [
                    {
                        expand: true,
                        cwd: 'node_modules/jquery/dist/',
                        src: ['jquery.js'],
                        dest: './../assets/jquery/'
                    },
                    {
                        expand: true,
                        cwd: 'node_modules/jquery-cycle/',
                        src: ['index.js'],
                        dest: './../assets/jquery-cycle/'
                    }
                ]
            }]
    });
    grunt.loadNpmTasks('grunt-contrib-copy');
    grunt.registerTask('default', ['copy']);
};
