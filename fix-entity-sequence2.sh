#!/bin/bash

# ========= CONFIGURATION ==========
jdlFile="jdl.jdl"
domainPath="src/main/java/com/mycompany/myapp/domain"
sequenceFile="src/main/resources/config/liquibase/changelog/00000000000099_sequences.xml"
masterFile="src/main/resources/config/liquibase/master.xml"
excluded=("AbstractAuditingEntity" "Authority" "User" "package-info" "Role" "PersistentToken")
# ==================================

# Read entities from JDL file
if [[ ! -f "$jdlFile" ]]; then
  echo "❌ JDL file not found: $jdlFile"
  exit 1
fi

echo "📄 Extracting entities from $jdlFile..."
mapfile -t entities < <(grep -E '^entity ' "$jdlFile" | awk '{print $2}' | sort | uniq)
echo "🔍 Detected entities: ${entities[*]}"

# Convert CamelCase to snake_case
to_snake_case() {
  echo "$1" | sed -E 's/([A-Z])/_\L\1/g' | sed -E 's/^_//'
}

# Update entity Java files
echo "🔧 Updating Java entity files..."
for entity in "${entities[@]}"; do
  entityFile="$domainPath/${entity}.java"
  if [[ -f "$entityFile" ]]; then
    sed -i '/@GeneratedValue/d' "$entityFile"
    sed -i '/@SequenceGenerator/d' "$entityFile"
    seq_name="$(to_snake_case "$entity")_seq"
    sed -i "/@Id/a\\
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = \"${entity}SeqGen\")\\
    @SequenceGenerator(name = \"${entity}SeqGen\", sequenceName = \"${seq_name}\", allocationSize = 50)
" "$entityFile"
    echo "✅ Updated: $entityFile"
  else
    echo "⚠️ File not found: $entityFile"
  fi
done

# Cleanup unused entities
echo ""
echo "🧹 Cleaning up obsolete entities..."
domainEntities=($(find "$domainPath" -name "*.java" | xargs -n1 basename | sed 's/.java//' | sort))
otherEntities=($(find src -type f \( -name "*.java" -o -name "*.xml" \) \
  | grep -E '/(dto|mapper|repository|web|changelog)/' \
  | sed -E 's/.*\/([A-Z][a-zA-Z0-9]+)(TestSamples|ResourceIT|Resource|DTO|Mapper|Service)?(\.java|\.xml)$/\1/' \
  | sort -u))
allEntities=($(printf "%s\n" "${domainEntities[@]}" "${otherEntities[@]}" | sort -u | uniq))

for oldEntity in "${allEntities[@]}"; do
  if [[ ! " ${entities[*]} " =~ " ${oldEntity} " && ! " ${excluded[*]} " =~ " ${oldEntity} " ]]; then
    echo "🗑️  Removing obsolete entity: $oldEntity"

    rm -f "$domainPath/${oldEntity}.java"
    rm -f src/main/java/com/mycompany/myapp/repository/${oldEntity}Repository.java
    rm -f src/main/java/com/mycompany/myapp/web/rest/${oldEntity}Resource.java
    rm -f src/main/java/com/mycompany/myapp/service/dto/${oldEntity}DTO.java
    rm -f src/main/java/com/mycompany/myapp/service/mapper/${oldEntity}Mapper.java
    rm -f src/main/java/com/mycompany/myapp/service/${oldEntity}Service.java
    rm -f src/test/java/com/mycompany/myapp/domain/${oldEntity}Test*.java
    rm -f src/test/java/com/mycompany/myapp/domain/${oldEntity}Asserts.java
    rm -f src/test/java/com/mycompany/myapp/web/rest/${oldEntity}ResourceIT.java
    find src/main/resources/config/liquibase/changelog -type f -iwholename "*${oldEntity}*.xml" -delete
    csv_file="src/main/resources/config/liquibase/fake-data/$(to_snake_case "$oldEntity").csv"
    rm -f "$csv_file"
  fi
done

# Generate Liquibase sequence file
echo ""
echo "📦 Generating Liquibase sequence file..."
cat <<EOF > "$sequenceFile"
<?xml version="1.0" encoding="utf-8"?>
<databaseChangeLog
    xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-latest.xsd">

    <changeSet id="00000000000099-1" author="jhipster">
EOF

for entity in "${entities[@]}"; do
  seq_name="$(to_snake_case "$entity")_seq"
  echo "        <createSequence sequenceName=\"$seq_name\" startValue=\"1\" incrementBy=\"50\"/>" >> "$sequenceFile"
done

echo "    </changeSet>" >> "$sequenceFile"

# Generate reset sequence SQL
echo "" >> "$sequenceFile"
echo "    <changeSet id=\"00000000000099-2\" author=\"jhipster\" context=\"faker\">" >> "$sequenceFile"
for entity in "${entities[@]}"; do
  table_name="$(to_snake_case "$entity")"
  seq_name="${table_name}_seq"
  echo "        <sql dbms=\"postgresql\">" >> "$sequenceFile"
  echo "            SELECT setval('${seq_name}', COALESCE((SELECT MAX(id) FROM ${table_name}), 0));" >> "$sequenceFile"
  echo "        </sql>" >> "$sequenceFile"
done
echo "    </changeSet>" >> "$sequenceFile"
echo "</databaseChangeLog>" >> "$sequenceFile"

echo "✅ Sequence file generated: $sequenceFile"

# Remove invalid includes from master.xml
echo ""
echo "🧽 Removing invalid <include> entries from master.xml..."
grep '<include file=' "$masterFile" | while IFS= read -r line; do
  incFile=$(echo "$line" | sed -nE 's/.*<include file="([^"]+)".*/\1/p')
  actualPath="src/main/resources/$incFile"
  if [[ -n "$incFile" && ! -f "$actualPath" ]]; then
    echo "🧽 Removing include: $incFile"
    sed -i.bak "\|<include file=\"$incFile\"|d" "$masterFile"
  fi
done

# Add sequence file to master.xml if missing
echo ""
echo "📘 Updating master.xml..."
include_line='    <include file="config/liquibase/changelog/00000000000099_sequences.xml" relativeToChangelogFile="false"/>'
needle='<!-- jhipster-needle-liquibase-add-incremental-changelog'

if ! grep -Fq "$include_line" "$masterFile"; then
  sed -i.bak "/$needle/i\\
$include_line
" "$masterFile"
  echo "✅ Added sequence include to master.xml"
else
  echo "ℹ️  Sequence include already exists"
fi

echo ""
echo "✅ Done! You can now run: ./mvnw liquibase:update"
