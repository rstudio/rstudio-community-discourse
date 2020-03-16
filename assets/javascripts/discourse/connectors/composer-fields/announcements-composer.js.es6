export default {
  setupComponent(attrs, ctx) {
    const model = attrs.model;
    const settings = ctx.siteSettings;
    
    ctx.set('showInputs', model.categoryId == settings.ads_category);
    
    model.addObserver('categoryId', () => {
      if (this._state === 'destroying') return;
      ctx.set('showInputs', model.categoryId == settings.ads_category);
    });
  }
}