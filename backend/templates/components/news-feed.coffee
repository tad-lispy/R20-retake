View      = require "teacup-view"
_         = require "lodash"
_.string  = require "underscore.string"
moment    = require "moment"

item      = new View
  components: __dirname
  View (options = {}) ->
    options = _.defaults options,
      url   : "#"
      icons : [ "cogs" ]
      class : "default"
      body  : => @translate "Something happened."
      footer: if options.time? then moment(options.time).fromNow() else ""

    @div class: "panel panel-default", =>
      @a
        href  : options.url
        class: "panel-body list-group-item", =>
        =>
          @div class: "media", =>

            @div class: "pull-left text-" + options.class, =>
              @span class: "media-object fa-stack fa-2x", =>
                @i class: "fa fa-stack-2x fa-" + options.icons[0]
                @i class: "fa fa-stack-1x fa-" + options.icons[1] if options.icons[1]?

            @div class: "media-body", =>
              if typeof options.body is "function" then do options.body
              else @p options.body

              if options.excerpt?
                if typeof options.excerpt is "function" then do options.excerpt
                else @div class: "excerpt", =>
                  @strong _.string.stripTags @render => @markdown options.excerpt

          @p class: "text-right", =>
            @small options.footer

module.exports = new View
  components: __dirname
  (options = {}) ->

    _(options).defaults
      entries: []

    {
      entries
    } = options

    @div class: "news-feed", =>
      mentioned =
        stories   : []
        questions : []
        answers   : []

      for entry in entries

        switch entry.model
          # Stories related entries
          # -----------------------

          when "Story" then switch entry.action

            when "apply"
              applied = entry.data._entry

              switch applied.action
                when "draft"
                  if applied.data._id.toHexString() in mentioned.stories then continue
                  else mentioned.stories.push applied.data._id.toHexString()

                  item
                    icons   : [ "plus" ]
                    url     : "/stories/#{applied.data._id}/"
                    footer  : @cede =>
                        if applied.meta.author._id.equals entry.meta.author._id
                          @translate "%s applied his own draft to a story",
                            entry.meta?.author?.name
                        else
                          @translate "%s applied a draft by %s to a story",
                            entry.meta?.author?.name
                            applied.meta.author.name
                    body    : =>
                     @p class: "excerpt", =>
                       @i class: "fa fa-fw text-muted fa-comment"
                       @em _.string.stripTags @render =>
                         @markdown applied.data.text or "UNPUBLISHED"
                    class   : "success"
                when "reference"
                  item
                    icons   : [ "link" ]
                    url     : "/stories/#{applied.data.main?._id or applied.populated "data.main"}/"
                    footer  : @cede => @translate "%s applied a question reference to a story.",
                      entry.meta?.author?.name
                    body    : =>
                      @p class: "excerpt", =>
                        @i class: "fa fa-fw text-muted fa-comment"
                        @em _.string.stripTags @render =>
                          @markdown applied.data.main?.text or "UNPUBLISHED"
                      @p
                        style: """
                          text-overflow: ellipsis;
                          white-space: nowrap;
                          overflow: hidden;
                        """
                        =>
                          @i class: "fa fa-fw text-muted fa-question-circle"
                          @strong _.string.stripTags @render =>
                            @markdown applied.data.referenced?.text or "UNPUBLISHED"
                    time    : do entry._id.getTimestamp
                    class   : "info"


          # Questions related entries
          # -------------------------

          when "Question" then switch entry.action

            when "apply"
              applied = entry.data._entry
              if applied.data._id.toHexString() in mentioned.questions then continue
              else mentioned.questions.push applied.data._id.toHexString()

              item
                icons   : [ "plus" ]
                url     : "/questions/#{applied.data._id}/"
                footer  : @cede =>
                  if applied.meta.author._id.equals entry.meta.author._id
                    @translate "%s published his own question",
                      applied.meta.author.name
                  else
                    @translate "%s approved a draft of a question by %s",
                      entry.meta.author.name,
                      applied.meta.author.name

                body    : =>
                  @i class: "fa fa-fw text-muted fa-question-circle"
                  @strong applied.data.text
                time    : do entry._id.getTimestamp
                class   : "success"

          # Answers related entries
          # -------------------------

          when "Answer"
            switch entry.action

              when "apply"
                applied   = entry.data._entry
                if applied.data._id.toHexString() in mentioned.answers then continue
                else mentioned.answers.push applied.data._id.toHexString()

                if not applied.data.question
                  continue

                item
                  icons   : [ "plus" ]
                  url     : "/questions/#{applied.data.question?._id}##{applied.data._id}/"
                  body    : =>
                    @p =>
                      @i class: "fa fa-fw text-muted fa-question-circle"
                      @strong applied.data.question.text
                    @p
                      style: """
                        text-overflow: ellipsis;
                        white-space: nowrap;
                        overflow: hidden;
                      """
                      =>
                        @i class: "fa fa-fw text-muted fa-puzzle-piece"

                        @em _.string.stripTags @render =>
                          @markdown applied.data.text

                  footer  : @cede =>
                    if applied.meta.author._id.equals entry.meta.author._id
                      @translate "%s published his own answer",
                        applied.meta.author.name
                    else
                      @translate "%s approved a draft of an answer by %s",
                        entry.meta.author.name,
                        applied.meta.author.name
                  class   : "success"


          # TODO: only in debug
          else
            if process.env.NODE_ENV is "development" then item
              time    : do entry._id.getTimestamp
