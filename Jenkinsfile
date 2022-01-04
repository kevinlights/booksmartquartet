pipeline {
	agent {
		docker {
			image 'barichello/godot-ci:3.3.2'
			args '-u root --privileged'
		}
	}
	environment {
		BUTLER_API_KEY    = credentials('butler')
		ITCHIO_GAME       = 'booksmart-quartets'
		ITCHIO_USERNAME   = 'armen138'
	}
	stages {
		stage('Build Windows') {
			steps {
				echo 'Building for Windows'
				sh "mkdir ${ITCHIO_GAME}_windows"
				sh "godot  -v --export 'Windows Desktop' ./${ITCHIO_GAME}_windows/${ITCHIO_GAME}.exe"
				sh "zip -r ${ITCHIO_GAME}_windows.zip ${ITCHIO_GAME}_windows"
				archiveArtifacts artifacts: '*.zip', fingerprint: true
			}
		}
		stage('Build Linux') {
			steps {
				echo 'Building for Linux'
				sh "mkdir ${ITCHIO_GAME}_linux"
				sh "godot -v --export Linux/X11 ./${ITCHIO_GAME}_linux/${ITCHIO_GAME}.x86_64"
				sh "tar -zcvf ${ITCHIO_GAME}_linux.tar.gz ${ITCHIO_GAME}_linux"
				archiveArtifacts artifacts: '*.tar.gz', fingerprint: true
			}
		}
		stage('Build MacOS') {
			steps {
				echo 'Building for MacOS'
				sh "godot -v --export 'Mac OSX' ./${ITCHIO_GAME}_macos.zip"
				archiveArtifacts artifacts: '*.zip', fingerprint: true
			}
		}
		stage('Build HTML5') {
			steps {
				echo 'Building for HTML5'
				sh "mkdir -v -p ${ITCHIO_GAME}_web"
				sh "godot -v --export 'HTML5' ./${ITCHIO_GAME}_web/index.html"
				sh "zip -r ${ITCHIO_GAME}_web.zip ${ITCHIO_GAME}_web"
				archiveArtifacts artifacts: '${ITCHIO_GAME}_web.zip', fingerprint: true
			}
		}
		stage('Deploy HTML5 to itch.io') {
			steps {
				sh "butler push ./${ITCHIO_GAME}_web.zip $ITCHIO_USERNAME/$ITCHIO_GAME:html"
			}
		}
		stage('Deploy Windows to itch.io') {
			steps {
				sh "butler push ./${ITCHIO_GAME}_windows.zip $ITCHIO_USERNAME/$ITCHIO_GAME:windows"
			}
		}
		stage('Deploy Linux to itch.io') {
			steps {
				sh "butler push ./${ITCHIO_GAME}_linux.tar.gz $ITCHIO_USERNAME/$ITCHIO_GAME:linux"
			}
		}
		stage('Deploy Mac to itch.io') {
			steps {
				sh "butler push ./${ITCHIO_GAME}_macos.zip $ITCHIO_USERNAME/$ITCHIO_GAME:mac"
			}
		}
	}
	post {
		always {
			cleanWs()
		}
	}
}
