pipeline {
    agent any
    options {
        timeout(time: 1, unit: 'HOURS')
        timestamps
        disableConcurrentBuilds()
    }
    triggers {
        cron 'H H/4 * * *'
    }

    stages {
        stage('Prepare run') {
            steps {
                echo 'empty'
            }
        }
        stage('Haxe 3.4.7') {
            environment { 
                VERSION_FOLDER = 'versions/Haxe-3.4.7'
            }
            steps {
                echo 'Preparing'
                sh '''
                cd $VERSION_FOLDER
                ln -sfn ../../benchmark.sh . 
                ln -sfn ../../build 
                ln -sfn ../../buildAll.hxml . 
                ln -sfn ../../buildConvertCsv.hxml 
                ln -sfn ../../data 
                ln -sfn ../../haxe3_libraries/ haxe_libraries 
                ln -sfn ../../haxelib.json . 
                ln -sfn ../../results/Haxe-3.4.7 results 
                ln -sfn ../../src 
                ln -sfn ../../srcPages 
                '''

                echo 'update lix dependencies'
                sh '''
                cd $VERSION_FOLDER
                lix download 
                lix install haxelib:hxcpp 
                '''

                echo 'Build targets'
                sh '''
                cd $VERSION_FOLDER
                haxe buildAll.hxml
                '''

                echo 'Run benchmark'
                sh '''
                cd $VERSION_FOLDER
                readonly VER=`haxe -version`
                echo "Running Haxe $VER benchmark"
                ./benchmark.sh -s data/haxe/std -s data/openfl/src -s data/lime/src | tee results.csv
                '''

                echo 'Convert data'
                sh '''
                cd $VERSION_FOLDER
                haxe buildConvertCsv.hxml
                '''
            }
        }
        stage('Haxe 4.0.1') {
            environment { 
                VERSION_FOLDER = 'versions/Haxe-4.0.1'
            }
            steps {
                echo 'Preparing'
                sh '''
                cd $VERSION_FOLDER
                ln -sfn ../../benchmark.sh . 
                ln -sfn ../../build 
                ln -sfn ../../buildAll.hxml . 
                ln -sfn ../../buildConvertCsv.hxml 
                ln -sfn ../../data 
                ln -sfn ../../haxe_libraries/ haxe_libraries 
                ln -sfn ../../haxelib.json . 
                ln -sfn ../../results/Haxe-4.0.1 results 
                ln -sfn ../../src 
                ln -sfn ../../srcPages 
                '''

                echo 'update lix dependencies'
                sh '''
                cd $VERSION_FOLDER
                lix download 
                lix install haxelib:hxcpp 
                '''

                echo 'Build targets'
                sh '''
                cd $VERSION_FOLDER
                haxe buildAll.hxml
                '''

                echo 'Run benchmark'
                sh '''
                cd $VERSION_FOLDER
                readonly VER=`haxe -version`
                echo "Running Haxe $VER benchmark"
                ./benchmark.sh -s data/haxe/std -s data/openfl/src -s data/lime/src | tee results.csv
                '''

                echo 'Convert data'
                sh '''
                cd $VERSION_FOLDER
                haxe buildConvertCsv.hxml
                '''
            }
        }
        stage('Haxe nightly') {
            environment { 
                VERSION_FOLDER = 'versions/Haxe-nightly'
            }
            steps {
                echo 'Preparing'
                sh '''
                cd $VERSION_FOLDER
                ln -sfn ../../benchmark.sh . 
                ln -sfn ../../build 
                ln -sfn ../../buildAll.hxml . 
                ln -sfn ../../buildConvertCsv.hxml 
                ln -sfn ../../data 
                ln -sfn ../../haxe_libraries/ haxe_libraries 
                ln -sfn ../../haxelib.json . 
                ln -sfn ../../results/Haxe-nightly results 
                ln -sfn ../../src 
                ln -sfn ../../srcPages 
                '''

                echo 'update lix dependencies'
                sh '''
                cd $VERSION_FOLDER
                lix download haxe nightly
                lix use haxe nightly
                lix download
                lix install haxelib:hxcpp
                '''

                echo 'Build targets'
                sh '''
                cd $VERSION_FOLDER
                haxe buildAll.hxml
                '''

                echo 'Run benchmark'
                sh '''
                cd $VERSION_FOLDER
                readonly VER=`haxe -version`
                echo "Running Haxe $VER benchmark"
                ./benchmark.sh -s data/haxe/std -s data/openfl/src -s data/lime/src | tee results.csv
                '''

                echo 'Convert data'
                sh '''
                cd $VERSION_FOLDER
                haxe buildConvertCsv.hxml
                '''
            }
        }
    }
}