import groovy.json.JsonOutput

node ('ec2'){
     
  stage 'Pull from SCM'  
  //Passing the pipeline the ID of my GitHub credentials and specifying the repo for my app
  git credentialsId: '32f2c3c2-c19e-431a-b421-a4376fce1186', url: 'https://github.com/nik786/pythona-app-test.git'
  stage 'Build and publish docker image'
  docker.withRegistry('https://758637906269.dkr.ecr.us-east-1.amazonaws.com/connector-dev', 'ecr:us-east-1:aws_cred_id') {
    docker.build("${env.BUILD_NUMBER}")
  }
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
}
