editorView = require("./editor-view.coffee")
invitationsView = require("./invitations-view.coffee")
onboardingView = require("./onboarding-view.coffee")
demoWarningView = require("./demo-warning-view.coffee")
{renderable, div} = require("teacup")

module.exports = renderable ({editor, list, isDemo}) ->
  div ".row", ->
    div ".col-md-3 clearfix", style: "background: #f9f9f9; border-radius: 5px; margin-top: 20px;", ->
      editorView(editor)

    div ".col-md-9", ->
      invitationsView(list)

      if list.invitations.length < 2
        onboardingView()

      if isDemo and list.invitations.length >= 2
        demoWarningView()
