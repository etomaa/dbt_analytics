---defining a dbt model for the parsed_fb_post table---
with stg_dim_facebook_posts AS
  (
     SELECT
       post_id as post_id,
       message as dsc_message,
       created_at as dt_created_at,
       status_type as dsc_status_type,
       media_type as dsc_media_type,
       reaction_count as mtr_reaction_count,
       viewer_reaction as dsc_viewer_reaction,
       comment_count as mtr_comment_count,
       share_count as mtr_share_count

    FROM {{ ref('parsed_fb_posts')}}

  ),

  transformed_posts AS (
    SELECT
       post_id,
       dsc_message , 
       CASE WHEN dsc_message IS NULL THEN "shared" ELSE "original" END AS dsc_message_type,
       --COALESCE(message,'shared post') as dsc_message,
       CAST(date(dt_created_at) AS DATE) AS sk_date,
       dt_created_at,
       dsc_status_type,
       COALESCE(dsc_media_type, 'onlytext') as dsc_media_type,
       mtr_reaction_count,
       dsc_viewer_reaction,
       mtr_comment_count,
       COALESCE(mtr_share_count, '0') as mtr_share_count
    FROM stg_dim_facebook_posts

  )

  SELECT
  {{dbt_utils.generate_surrogate_key(['post_id', 'dt_created_at'])}} AS sk_post_id,
   *
  FROM transformed_posts
