const markdown = require('markdown-it')().
	  use(require('markdown-it-plantuml'),{
		  imageFormat: 'svg'
	  });
global.Markdown = markdown;
