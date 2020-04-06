deploy () {
  # Create a deployment package.
  cd ..
  chmod go+r slide.py
  zip package.zip slide.py $1.py

  # Create the close function
  aws lambda update-function-code --function-name $1 --zip-file fileb://package.zip
  rm package.zip

  # Invoke the close function
  #aws lambda invoke --function-name $1 out --log-type Tail --query 'LogResult' --output text |  base64 -d

  cd -
}

deploy slide_lambda