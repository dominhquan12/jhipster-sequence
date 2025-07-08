#!/bin/bash

# ========= CONFIGURATION ==========
jdlFile="jdl.jdl"
jhipsterFolder=".jhipster"
domainPath="src/main/java/com/mycompany/myapp/domain"
repositoryPath="src/main/java/com/mycompany/myapp/repository"
webRestPath="src/main/java/com/mycompany/myapp/web/rest"
changeLogPath="src/main/resources/config/liquibase/changelog"
fakeDataPath="src/main/resources/config/liquibase/fake-data"
testDomainPath="src/test/java/com/mycompany/myapp/domain"
testWebRestPath="src/test/java/com/mycompany/myapp/web/rest"
sequenceFile="src/main/resources/config/liquibase/changelog/00000000000099_sequences.xml"
masterFile="src/main/resources/config/liquibase/master.xml"
excluded=("AbstractAuditingEntity" "Authority" "User" "package-info" "Role" "PersistentToken")
# ==================================

toPascalCase() {
  local input="$1"
  local output=""
  IFS='_' read -ra parts <<< "$input"
  for part in "${parts[@]}"; do
    output+="${part^}"
  done
  echo "$output"
}

# Exit if JDL file not found
if [[ ! -f "$jdlFile" ]]; then
  echo "❌ JDL file not found: $jdlFile"
  exit 1
fi

# Convert CamelCase to snake_case
to_snake_case() {
  echo "$1" | sed -E 's/([A-Z])/_\L\1/g' | sed -E 's/^_//'
}

# Convert CamelCase to kebab-case
to_kebab_case() {
  echo "$1" | sed -E 's/([a-z0-9])([A-Z])/\1-\L\2/g' | sed -E 's/^([A-Z])/\L\1/' | tr '[:upper:]' '[:lower:]'
}

# Read current entities from JDL
echo "📦 Reading entities from JDL..."
mapfile -t currentEntities < <(grep -E '^entity ' "$jdlFile" | awk '{print $2}' | sort | uniq)

# Read old entities from .jhipster configs
echo "🗃️  Scanning existing entity configs..."
#mapfile -t existingEntities < <(
#  find src -type f \( -name "*.java" -o -name "*.xml" \) \
#    | grep -E '/(domain|repository|web/rest|changelog)/' \
#    | sed -E 's|.*/([A-Z][a-zA-Z0-9]+)(TestSamples|ResourceIT|Resource)?(\.java|\.xml)$|\1|' \
#    | sort -u
#)

## remove file json in .jhipster
mapfile -t jhipsterEntities < <(
  find .jhipster -type f -name "*.json" \
    | sed -E 's|.*/([A-Za-z0-9]+)\.json$|\1|' \
    | sort -u
)

mapfile -t obsoleteJhipsterEntities < <(comm -23 <(printf "%s\n" "${jhipsterEntities[@]}" | sort) <(printf "%s\n" "${currentEntities[@]}" | sort))

for oldEntity in "${obsoleteJhipsterEntities[@]}"; do
  [[ " ${excluded[*]} " =~ " ${oldEntity} " ]] && continue
  echo "Removing: $jhipsterFolder/${oldEntity}.json"
  rm -f "$jhipsterFolder/${oldEntity}.json"
done

## remove file java in domain
mapfile -t domainEntities < <(
  find "$domainPath" -type f -name "*.java" ! -name "package-info.java" \
    | sed -E 's|.*/([A-Za-z0-9]+)\.java$|\1|' \
    | sort -u
)

mapfile -t obsoleteDomainEntities < <(comm -23 <(printf "%s\n" "${domainEntities[@]}" | sort) <(printf "%s\n" "${currentEntities[@]}" | sort))

for oldEntity in "${obsoleteDomainEntities[@]}"; do
  [[ " ${excluded[*]} " =~ " ${oldEntity} " ]] && continue
  echo "Removing: $domainPath/${oldEntity}.java"
  rm -f "$domainPath/${oldEntity}.java"
done

## remove file java in repository
mapfile -t repositoryEntities < <(
  find "$repositoryPath" -type f -name "*.java" ! -name "package-info.java" \
    | sed -E 's|.*/([A-Za-z0-9]+)\.java$|\1|' \
    | sed -E 's|Repository$||' \
    | sort -u
)

mapfile -t obsoleteRepositoryEntities < <(comm -23 <(printf "%s\n" "${repositoryEntities[@]}" | sort) <(printf "%s\n" "${currentEntities[@]}" | sort))

for oldEntity in "${obsoleteRepositoryEntities[@]}"; do
  [[ " ${excluded[*]} " =~ " ${oldEntity} " ]] && continue
  echo "Removing: $repositoryPath/${oldEntity}Repository.java"
  rm -f "$repositoryPath/${oldEntity}Repository.java"
done

## remove file java in web/rest
excludedWebRest=("Account" "AuthInfo" "Authority" "Logout" "PublicUser")
mapfile -t webRestEntities < <(
  find "$webRestPath" -maxdepth 1 -type f -name "*.java" ! -name "package-info.java" \
    | sed -E 's|.*/([A-Za-z0-9]+)\.java$|\1|' \
    | sed -E 's|Resource$||' \
    | sort -u
)

mapfile -t obsoleteWebRestEntities < <(comm -23 <(printf "%s\n" "${webRestEntities[@]}" | sort) <(printf "%s\n" "${currentEntities[@]}" | sort))

for oldEntity in "${obsoleteWebRestEntities[@]}"; do
  [[ " ${excludedWebRest[*]} " =~ " ${oldEntity} " ]] && continue
  echo "Removing: $webRestPath/${oldEntity}Resource.java"
  rm -f "$webRestPath/${oldEntity}Resource.java"
done



## remove file xml in changelog
mapfile -t changeLogEntities < <(
  find "$changeLogPath" -type f -name "*.xml" \
    | grep 'added_entity' \
    | sed -E 's|.*/[0-9]+_added_entity(_constraints)?_([A-Za-z0-9]+)\.xml$|\2|' \
    | sort -u
)

mapfile -t obsoletechangeLogEntities < <(comm -23 <(printf "%s\n" "${changeLogEntities[@]}" | sort) <(printf "%s\n" "${currentEntities[@]}" | sort))

for oldEntity in "${obsoletechangeLogEntities[@]}"; do
  find "$changeLogPath" -type f -name "*${oldEntity}.xml" | while read -r file; do
    echo "🗑️ Removing: $file"
    rm -f "$file"
  done
done


## remove file csv in fake-data
mapfile -t rawCsvNames < <(
  find "$fakeDataPath" -type f -name "*.csv" \
    | sed -E 's|.*/([A-Za-z0-9_]+)\.csv$|\1|' \
    | sort -u
)

fakeDataEntities=()
for name in "${rawCsvNames[@]}"; do
  fakeDataEntities+=( "$(toPascalCase "$name")" )
done

mapfile -t obsoleteFakeDataEntities < <(comm -23 <(printf "%s\n" "${fakeDataEntities[@]}" | sort) <(printf "%s\n" "${currentEntities[@]}" | sort))

for oldEntity in "${obsoleteFakeDataEntities[@]}"; do
  echo "Removing: $fakeDataPath/$(to_snake_case "$oldEntity").csv"
  rm -f "$fakeDataPath/$(to_snake_case "$oldEntity").csv"
done

## remove file java in test/domain

mapfile -t testDomainEntities < <(
  find "$testDomainPath" -type f -name "*.java" \
    | sed -E 's|.*/([A-Za-z0-9]+)\.java$|\1|' \
    | sed -E 's/(TestSamples|Test|Asserts)$//' \
    | sort -u
)

mapfile -t obsoleteTestDomainEntities < <(comm -23 <(printf "%s\n" "${testDomainEntities[@]}" | sort) <(printf "%s\n" "${currentEntities[@]}" | sort))

testDomainExcluded=("AssertUtils" "Authority")
for oldEntity in "${obsoleteTestDomainEntities[@]}"; do
  [[ " ${testDomainExcluded[*]} " =~ " ${oldEntity} " ]] && continue
  echo "Removing: $testDomainPath/${oldEntity}Asserts.java"
  rm -f "$testDomainPath/${oldEntity}Asserts.java"
  echo "Removing: $testDomainPath/${oldEntity}Test.java"
  rm -f "$testDomainPath/${oldEntity}Test.java"
  echo "Removing: $testDomainPath/${oldEntity}TestSamples.java"
  rm -f "$testDomainPath/${oldEntity}TestSamples.java"
done

## remove file java in src/test/java/com/mycompany/myapp/web/rest
mapfile -t testWebRestEntities < <(
  find "$testWebRestPath" -maxdepth 1 -type f -name "*.java" \
    | sed -E 's|.*/([A-Za-z0-9]+)\.java$|\1|' \
    | sed -E 's/(ResourceIT)$//' \
    | sort -u
)

mapfile -t obsoleteTestWebRestEntities < <(comm -23 <(printf "%s\n" "${testWebRestEntities[@]}" | sort) <(printf "%s\n" "${currentEntities[@]}" | sort))
testWebRestExcluded=("Account" "Authority" "Logout" "PublicUser" "TestUtil" "User" "WithUnauthenticatedMockUser")
for oldEntity in "${obsoleteTestWebRestEntities[@]}"; do
  [[ " ${testWebRestExcluded[*]} " =~ " ${oldEntity} " ]] && continue
  echo "Removing: $testWebRestPath/${oldEntity}ResourceIT.java"
  rm -f "$testWebRestPath/${oldEntity}ResourceIT.java"

done

# Update @GeneratedValue & @SequenceGenerator for current entities
echo ""
echo "🔧 Updating entity ID strategies..."
for entity in "${currentEntities[@]}"; do
  javaFile="$domainPath/${entity}.java"
  [[ ! -f "$javaFile" ]] && continue

  sed -i '/@GeneratedValue/d' "$javaFile"
  sed -i '/@SequenceGenerator/d' "$javaFile"
  seq_name="$(to_snake_case "$entity")_seq"
  sed -i "/@Id/a\\
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = \"${entity}SeqGen\")\\
    @SequenceGenerator(name = \"${entity}SeqGen\", sequenceName = \"${seq_name}\", allocationSize = 50)
" "$javaFile"
done

# Generate Liquibase sequences
echo ""
echo "🧬 Generating Liquibase sequence file..."
cat <<EOF > "$sequenceFile"
<?xml version="1.0" encoding="utf-8"?>
<databaseChangeLog
    xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-latest.xsd">

    <changeSet id="00000000000099-1" author="jhipster">
EOF

for entity in "${currentEntities[@]}"; do
  echo "        <createSequence sequenceName=\"$(to_snake_case "$entity")_seq\" startValue=\"1\" incrementBy=\"50\"/>" >> "$sequenceFile"
done

echo "    </changeSet>" >> "$sequenceFile"
echo "    <changeSet id=\"00000000000099-2\" author=\"jhipster\" context=\"faker\">" >> "$sequenceFile"
for entity in "${currentEntities[@]}"; do
  snake="$(to_snake_case "$entity")"
  echo "        <sql dbms=\"postgresql\">" >> "$sequenceFile"
  echo "            SELECT setval('${snake}_seq', COALESCE((SELECT MAX(id) FROM ${snake}), 0));" >> "$sequenceFile"
  echo "        </sql>" >> "$sequenceFile"
done
echo "    </changeSet>" >> "$sequenceFile"
echo "</databaseChangeLog>" >> "$sequenceFile"

# Remove invalid <include> tags from master.xml
echo ""
echo "🗑️  Cleaning up unused <include> from master.xml..."
grep '<include file=' "$masterFile" | while IFS= read -r line; do
  incFile=$(echo "$line" | sed -nE 's/.*<include file="([^"]+)".*/\1/p')
  fullPath="src/main/resources/$incFile"
  [[ ! -f "$fullPath" ]] && sed -i "\|<include file=\"$incFile\"|d" "$masterFile"
done

# Ensure the sequence file is included
echo ""
echo "📘 Ensuring sequence file is included in master.xml..."
include_line='    <include file="config/liquibase/changelog/00000000000099_sequences.xml" relativeToChangelogFile="false"/>'
needle='<!-- jhipster-needle-liquibase-add-incremental-changelog'

if ! grep -Fq "$include_line" "$masterFile"; then
  sed -i "/$needle/i\\
$include_line
" "$masterFile"
  echo "✅ Sequence include added."
else
  echo "ℹ️ Sequence include already present."
fi

echo ""
echo "✅ Done! Now run: ./mvnw liquibase:update"

