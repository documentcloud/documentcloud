window.ModelWithLanguageMixin = {

  LANGUAGE_CHOICES: {
      en: 'English',
      es: 'Spanish',
      hi: 'Hindi',
      pt: 'Portuguese',
      ru: 'Russian',
      ja: 'Japanese',
      de: 'German',
      id: 'Malay/Indonesian',
      vi: 'Vietnamese',
      ko: 'Korean',
      fr: 'French',
      fa: 'Persian',
      tk: 'Turkish',
      it: 'Italian',
      no: 'Norwegian',
      pl: 'Polish',
      chi: 'Chinese (simplified)',
      zho: 'Chinese (traditional)',
      ar: 'Aribic',
      th: 'Thai'
  },

  getLanguageCode: function(){
    return this.get('language') || 'en';
  },

  getLanguageName: function(){
    return this.LANGUAGE_CHOICES[ this.getLanguageCode() ];
  },

  getLanguage: function(){
    return { code: this.getLanguageCode(), name: this.getLanguageName() };
  }

};
