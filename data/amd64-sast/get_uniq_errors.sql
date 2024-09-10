SELECT DISTINCT
    python_version as 'Python Version',
    location.physicalLocation.artifactLocation.uri as path,
    location.physicalLocation.region.startLine as line,
    message.text,
FROM (
    SELECT
        unnest(from_json(result.locations, '["JSON"]')) as location,
        result.message,
        python_version,
        file_path,
        build_id
    FROM (
        SELECT
            unnest(from_json(run.results, '["JSON"]')) as result,
            python_version,
            file_path,
            build_id
        FROM (
            SELECT
            unnest(from_json(file_content.runs, '["JSON"]')) as run,
            python_version,
            file_path,
            build_id
            FROM sarif_data
        )
    )
)
