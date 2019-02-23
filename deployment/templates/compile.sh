echo 'rendering templates'
rm "../deployment.yaml"
tag=`git describe --abbrev=0 --tags`
for file in *.mustache
do
  output_file="${file%.*}"
  echo "rendering :: $output_file"
  echo "# source ($tag) = $output_file" >> "../deployment.yaml"
  mustache values.yaml "$file" > "../$output_file"
  cat "../$output_file" >> "../deployment.yaml"
  echo "---" >> "../deployment.yaml"
done