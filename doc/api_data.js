define({ "api": [
  {
    "type": "get",
    "url": "/api/pets",
    "title": "Info for a specific pet",
    "group": "Pet",
    "parameter": {
      "fields": {
        "Parameter": [
          {
            "group": "Parameter",
            "type": "Number",
            "optional": false,
            "field": "limit",
            "description": "<p>Limit of records to show</p>"
          },
          {
            "group": "Parameter",
            "type": "Number",
            "optional": false,
            "field": "page",
            "description": "<p>Page for pagination</p>"
          }
        ]
      }
    },
    "sampleRequest": [
      {
        "url": "http://test.github.com/some_path/"
      }
    ],
    "name": "showPetById",
    "version": "0.0.0",
    "filename": "./app/api/pets.rb",
    "groupTitle": "Pet"
  }
] });
