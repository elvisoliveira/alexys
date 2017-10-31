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
        }],
        sass: {
            dist: {
                options: {
                    style: 'expanded',
                    sourcemap: 'file',
                    lineNumbers: true
                },
                files: {
                    '../style.css': '../styles/styles.scss'
                }
            }
        },
        postcss: {
            options: {
                map: true,
                processors: [
                    require('cssnano')()
                ]
            },
            dist: {
                src: '../style.css'
            }
        },
        watch: {
            options: {
                spawn: false,
                livereload: true
            },
            sass: {
                files: [
                    '../styles/*.scss'
                ],
                tasks: ['sass', 'postcss']
            }
        }
    });

    grunt.loadNpmTasks('grunt-postcss');
    grunt.loadNpmTasks('grunt-contrib-sass');
    grunt.loadNpmTasks('grunt-contrib-copy');
    grunt.loadNpmTasks('grunt-contrib-watch');

    grunt.registerTask('default', ['copy', 'sass', 'postcss']);
    grunt.registerTask('develop', ['copy', 'sass', 'postcss', 'watch']);
};
