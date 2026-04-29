pipeline {
  agent any

  options {
    timestamps()
  }

  environment {
    SONARQUBE_SERVER = 'sonarqube'
    SONAR_SCANNER = 'SonarScanner'
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Install') {
      steps {
        dir('.') { sh 'npm ci' }
      }
    }

    stage('Test') {
      steps {
        dir('.') {
          sh 'cp .env.example .env'
          sh 'sh scripts/test-db-up.sh'
          sh 'npm test'
          sh 'sh scripts/test-db-down.sh'
        }
      }
    }

    stage('Sonar') {
      steps {
        script {
          def scannerHome = tool(env.SONAR_SCANNER)
          withSonarQubeEnv(env.SONARQUBE_SERVER) {
            sh "${scannerHome}/bin/sonar-scanner -Dproject.settings=sonar-project.properties"
          }
        }
      }
    }

    stage('Quality Gate') {
      steps {
        timeout(time: 5, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: false
        }
      }
    }
  }
}
