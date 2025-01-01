{{ config(materialized='view') }}

WITH raw_posts AS (
  SELECT
    id,
    message,
    created_at,
    status_type,

    -- Example: Extract media_type from attachments
    JSON_EXTRACT_SCALAR(media_type, '$.data[0].media_type') AS media_type,

    -- Reactions summary
   JSON_EXTRACT_SCALAR(reactions, '$.total_count') AS reaction_count,
   JSON_EXTRACT_SCALAR(reactions, '$.viewer_reaction') AS viewer_reaction,

    -- Comments summary
    JSON_EXTRACT_SCALAR(comments, '$.summary.total_count') AS comment_count,

    -- Shares
    JSON_EXTRACT_SCALAR(shares, '$.count') AS share_count,

    -- Keep the entire array of detailed reactions as JSON
    detailed_reactions
    FROM {{ ref('stg_raw_facebook_posts') }}
  ---FROM {{ source('facebook_source', 'personal_posts') }}
),

unnested_reactions AS (
  SELECT
    rp.id as post_id,
    rp.message,
    rp.created_at,
    rp.status_type,
    rp.media_type,
    rp.reaction_count,
    rp.viewer_reaction,
    rp.comment_count,
    rp.share_count,

    -- Unnest the array of detailed_reactions
    reaction_object
  FROM raw_posts rp
  LEFT JOIN UNNEST(
    JSON_EXTRACT_ARRAY(rp.detailed_reactions, '$')
  ) as reaction_object
  ON TRUE
)

SELECT
  post_id,
  message,
  created_at,
  status_type,
  media_type,
  reaction_count,
  viewer_reaction,
  comment_count,
  share_count

  -- parse each un-nested reaction object
  ---JSON_VALUE(reaction_object, '$.id')   as reactor_id,
  ---JSON_VALUE(reaction_object, '$.name') as reactor_name,
  ---JSON_VALUE(reaction_object, '$.type') as reaction_type

FROM unnested_reactions

