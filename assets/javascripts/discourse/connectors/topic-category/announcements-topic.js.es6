export default {
  shouldRender(attrs, ctx) {
    return attrs.topic.ad_url && attrs.topic.category_id == ctx.siteSettings.ads_category;
  }
}