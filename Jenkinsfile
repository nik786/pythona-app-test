import groovy.json.JsonOutput

timestamps {
 def deploy_Env = null
 def jobName = null
 def microSvcName = null
 def app
 //def gitCreds = 'AWGITTAPP'
 def gitCreds =  '32f2c3c2-c19e-431a-b421-a4376fce1186'
 def shortGitCommit = null
 def environment = null
 def branch = null



      final String STAGING     = "staging"
      final String PRODUCTION  = "production"

      def wepackCfg
      def imageTag
      def serviceName
      def taskFamily
      def dockerFilePrefix
      def clusterName


 if  (env.BRANCH_NAME == "staging") {
        wepackCfg         = ""
        imageTag          = ""
        serviceName       = ""
        taskFamily        = ""
        dockerFilePrefix  = STAGING
        clusterName       = ""
      } else if  (env.BRANCH_NAME == "master") {
        wepackCfg         = ""
        imageTag          = ""
        serviceName       = ""
        taskFamily        = ""
        dockerFilePrefix  = PRODUCTION
        clusterName       = ""
      }

      def remoteImageTag  = "${imageTag}-${BUILD_NUMBER}"
      def ecRegistry      = "https://758637906269.dkr.ecr.us-east-1.amazonaws.com/connector-dev"

}

stage('Execute Build') {
  node(ec2) {
   
  

   projectName = jobName.split(/\//)[1]
   branch = jobName.split(/\//)[3]
   environment = "${deploy_Env}"
   

try {
    stage('Build') {
     stage 'Cleanup'
     deleteDir()

     stage 'Checkout'
     checkout scm
     dir('pythona-app-test') {
      deleteDir()
      git url: "https://github.com/nik786/pythona-app-test.git", branch: "${branch}", credentialsId: "${gitCreds}"
      def GIT_COMMIT_HASH = sh(script: "git log -n 1 --pretty=format:'%H'", returnStdout: true)
      shortGitCommit = GIT_COMMIT_HASH[0..6]
      

      stage("Docker build") {  
        sh "docker build --no-cache -t repo:${remoteImageTag} \
                                    -f ${dockerFilePrefix}.Dockerfile ."
      }

     stage("Docker push") {
        // NOTE:
        //  ecr: is a required prefix
        //  eu-central-1: is the region where the Registery located
        //  aws-ecr: is the credentials ID located in the jenkins credentials
        //
        docker.withRegistry(ecRegistry, "ecr:eu-central-1:aws-ecr") {
          docker.image("repo:${remoteImageTag}").push(remoteImageTag)
		  currentBuild.result = 'SUCCESS'
        }
      }
    }
  }

	stage ('Deploy on ECS')
	IMAGE_NO = sh (
		script: 'aws ecr describe-images --repository-name connector-dev --query \'sort_by(imageDetails,& imagePushedAt)[-1].imageTags[0]\' --output text',
		returnStdout: true
	  ).trim()
	  echo "IMAGE_NO=${IMAGE_NO}"
    
    def payload = readJSON text: JsonOutput.toJson([
        region: "us-east-1", 
        service: "python-task",
        cluster: "connector-clus",
        image: "758637906269.dkr.ecr.us-east-1.amazonaws.com/connector-dev:"+IMAGE_NO
        ])
	String outputFile="imagepayload.json"
	writeJSON file: outputFile, json: payload, pretty: 2
	def svcURL="https://1scjp21jd2.execute-api.us-east-1.amazonaws.com/prod/service"
	sh "curl -X POST -H \"Content-Type: application/json\" -H \"x-api-key:6bKBEiiGF48qgdLymE4tO2GuTyklu8IZ6P1doBh8\" -d @${outputFile} ${svcURL}"
	currentBuild.result = 'SUCCESS' 

   stage('execute smoke test'){
            steps {
                  ansiblePlaybook \
                      playbook: '/etc/ansible/helo.yml',
                      inventory: '/etc/ansible/inventories/local.yml',
                      extraVars: [
                          ansible_ssh_user: "$SSH_USR",
                          ansible_ssh_pass: "$SSH_PSW",
                          ansible_become_pass: "$SSH_PSW",
                          current_directory: "$WORKSPACE"
                      ]
              }
        }

   stage('deployemt successful'){
            sh python /etc/ansible/helo.py
          }
 
   stage('deployemt notification'){
            sh  /etc/ansible/helo.sh
          }
		  
 catch (Exception err) {
    currentBuild.result = 'FAILURE'
   } finally {
    if (currentBuild.result == 'SUCCESS') {
     stage 'Announce'
   
    }
   }
}



