podTemplate(containers: [
  containerTemplate(name: 'docker', image: 'docker:1.11', command: 'cat', ttyEnabled: true),
  containerTemplate(name: 'python', image: 'python:3', command: 'cat', ttyEnabled: true),
  containerTemplate(name: 'aws', image: 'xueshanf/awscli:3.10-alpine', command: 'cat', ttyEnabled: true),
  containerTemplate(name: 'yq', image: 'mikefarah/yq:2.4.0', command: 'cat', ttyEnabled: true)
],
volumes: [
  hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
]){
    node(POD_LABEL){
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'tarikaws']]){
          stage('Build Image'){
            withCredentials([usernamePassword(credentialsId: 'tarikgit', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]){
              sh '''
              git config --global user.name $USERNAME
              git config --global user.email $USERNAME@gmail.com
              git clone -b dev https://$USERNAME:$PASSWORD@github.com/tarikweb/webjek.git
              cd webjek
              GIT_COMMIT="$(git rev-parse HEAD)"
              echo '###### Git START ########'
              echo $GIT_COMMIT
              echo '###### Git END ########'
              echo 'export IMAGE=489155402474.dkr.ecr.eu-west-1.amazonaws.com/webjek:'$GIT_COMMIT > ./load_env.sh
              echo 'export IMAGELATEST=489155402474.dkr.ecr.eu-west-1.amazonaws.com/webjek:latest' >> ./load_env.sh
              echo 'export GIT_COMMIT='$GIT_COMMIT >> ./load_env.sh
              echo 'export REPO=489155402474.dkr.ecr.eu-west-1.amazonaws.com/webjek' >> ./load_env.sh
              chmod 750 ./load_env.sh
              '''
              container('python'){
                  sh '''
                  cd webjek
                  pip3 install flask
                  '''
              }
            }
          }
          stage('Push Image In ECR'){
              container('aws'){
                  sh '''
                  cd webjek
                  aws ecr get-login --no-include-email --region eu-west-1 > Docker-Login

                  '''
              }
              container('docker'){
                  sh '''
                  cd webjek
                  cat Docker-Login
                  . ./load_env.sh
                  $(cat Docker-Login)
                  docker build -t $IMAGE .
                  docker tag $IMAGE $IMAGELATEST
                  docker push $IMAGE
                  docker push $IMAGELATEST
                  '''
              }
            }
            stage('Generate Report'){
                  sh '''
                  cd webjek
                  . ./load_env.sh
                  cd ..
                  mkdir report
                  cd report
                  echo '##############################################' > ./report.yaml
                  echo 'RapportDeBuild:' >> ./report.yaml
                  echo 'gitCommit: '$GIT_COMMIT >> ./report.yaml
                  echo 'imagesBuild : ' >> ./report.yaml
                  echo '  tagCommit : '$IMAGE >> ./report.yaml
                  echo '  tagLatest : '$IMAGELATEST >> ./report.yaml
                  echo '##############################################' >> ./report.yaml
                  cat ./report.yaml
                  '''
          }
        }
    }
}





