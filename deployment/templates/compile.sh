echo 'rendering templates'
for file in *.mustache
do
  output_file="${file%.*}"
  echo "rendering :: $output_file"
  mustache values.yaml "$file" > "../$output_file"
done