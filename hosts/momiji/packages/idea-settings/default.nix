{
  runCommand,
  python3,
  jdk21,
  jdk25,
}:
runCommand "intellij-idea-settings" {} ''
  ${python3}/bin/python ${./generate.py} \
    --output "$out" \
    --java21 ${jdk21.home} \
    --java25 ${jdk25.home}
''
