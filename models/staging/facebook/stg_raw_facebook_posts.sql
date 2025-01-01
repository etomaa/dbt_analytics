with raw_facebook_posts AS
  (
    SELECT 
      id,
      message,
      created_time as created_at,
      status_type,
      attachments as media_type,
      reactions,
      comments,
      shares,
      detailed_reactions
 FROM {{ source('facebook_source', 'personal_posts') }}
      
  )
SELECT
  *
FROM raw_facebook_posts

 