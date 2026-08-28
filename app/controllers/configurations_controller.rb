class ConfigurationsController < ApplicationController

  def ios_v1
    render json: {
      settings: {
        script_injections: [
          {
            id: 'init_turbo',
            url: 'https://assets.linlishenghuo.com/assets/turbo-00000001.digested.js'
          },
          {
            id: 'init',
            url: 'https://assets.linlishenghuo.com/assets/printer-00000102.digested.js'
          }
        ]
      },
      rules: [
        {
          patterns: [
            "/menus$"
          ],
          properties: {
            context: "modal",
            modal_style: "medium"
          }
        },
        {
          patterns: [
            "/why$"
          ],
          properties: {
            presentation: "replace_root"
          }
        },
        {
          patterns: [
            "/new$",
            "/edit$",
            "/modal"
          ],
          properties: {
            context: "modal",
            pull_to_refresh_enabled: false
          }
        },
        {
          patterns: [
            "^/$"
          ],
          properties: {
            presentation: "clear_all"
          }
        }
      ]
    }
  end

  def android_v1
    render json: {
      settings: {
        script_injections: [
          {
            id: 'init_turbo',
            url: 'https://assets.linlishenghuo.com/assets/turbo-00000001.digested.js'
          },
          {
            id: 'init',
            url: 'https://assets.linlishenghuo.com/assets/printer-00000102.digested.js'
          }
        ]
      },
      rules: [
        {
          patterns: [
            ".*"
          ],
          properties: {
            context: "default",
            uri: "hotwire://fragment/web",
            fallback_uri: "hotwire://fragment/web",
            pull_to_refresh_enabled: true
          }
        },
        {
          patterns: [
            "^$",
            "^/$"
          ],
          properties: {
            presentation: "clear_all",
            comment: "Clear navigation stack when visiting root page."
          }
        },
        {
          patterns: [
            "/new$",
            "/edit$",
            "/modal"
          ],
          properties: {
            context: "modal",
            pull_to_refresh_enabled: false
          }
        },
        {
          patterns: [
            ".+\\.(?:bmp|gif|heic|jpg|jpeg|png|svg|webp)"
          ],
          properties: {
            context: "modal",
            uri: "hotwire://fragment/image_viewer"
          }
        }
      ]
    }
  end
end
