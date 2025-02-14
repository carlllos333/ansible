pipeline {
    agent any
    
    parameters {
        string(name: 'ID', defaultValue: 'root', description: '')
        string(name: 'IPADDR1', defaultValue: '192.168.240.136', description: 'docker')
        string(name: 'IPADDR2', defaultValue: '192.168.240.134', description: 'apache')
    }

      stages {
        stage('Clonage du depot github') {
            steps {
                git url: 'https://github.com/dteixeiraef/pipeline-jenkins-github.git',
                    branch: 'main',
                    credentialsId: '1141550'
            }
        }
        stage('Envoie du script et des conteneurs sur la machine docker') {
            steps {
                sh '''
                scp script.sh $ID@$IPADDR1:/tmp/scriptdocker.sh
                scp -r docker $ID@$IPADDR1:/
                ssh $ID@$IPADDR1 "chmod +x /tmp/scriptdocker.sh"
                '''
            }
        }
        stage('execution du script sur la machine docker') {
            steps {
                sh '''
                ssh $ID@$IPADDR1 "bash /tmp/scriptdocker.sh"
                '''
            }
        }

        stage('envoie du script sur la machine apache') {
            steps {
                sh '''
                scp script.sh $ID@$IPADDR2:/tmp/scriptapache.sh
                ssh $ID@$IPADDR2 "chmod +x /tmp/scriptapache.sh"
                '''
            }
        }
        stage('execution du script sur la machine apache') {
            steps {
                sh '''
                ssh $ID@$IPADDR2 "bash /tmp/scriptapache.sh"
                '''
            }
        }

        stage('Envoie du script et des conteneurs sur la machine docker') {
            steps {
                sh '''
                ansible-playbook playbook-docker.yml playbook-apache.yml
                '''
            }
        }
    }
}
        