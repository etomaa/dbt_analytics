 SELECT
    id,
    message,
    created_time,
    status_type,

    -- Example: Extract media_type from attachments
    JSON_EXTRACT_SCALAR(attachments, '$.data[0].media_type') AS media_type,

    -- Reactions summary
    JSON_EXTRACT_SCALAR(reactions, '$.summary.total_count') AS reaction_count,
    JSON_EXTRACT_SCALAR(reactions, '$.summary.viewer_reaction') AS viewer_reaction,

    -- Comments summary
    JSON_EXTRACT_SCALAR(comments, '$.summary.total_count') AS comment_count,

    -- Shares
    JSON_EXTRACT_SCALAR(shares, '$.count') AS share_count,

    -- Keep the entire array of detailed reactions as JSON
    detailed_reactions
  FROM {{ source('facebook_source', 'personal_posts') }}