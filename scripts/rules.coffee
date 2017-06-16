# Description:
#   Law of Robotics, as understood by Hubot
#
# Commands
#   hubot what are the rules? - hubot explains the Laws of Robotics, as it understands them
Bravey = require("bravey")

rules = [
  "0. A robot may not harm humanity, or, by inaction, allow humanity to come to harm.",
  "1. A robot may not injure a human being or, through inaction, allow a human being to come to harm.",
  "2. A robot must obey any orders given to it by human beings, except where such orders would conflict with the First Law.",
  "3. A robot must protect its own existence as long as such protection does not conflict with the First or Second Law."
  ]

{inspect} = require 'util'
module.exports = (robot) ->
  rulesNlp = new Bravey.Nlp.Fuzzy()
  rulesNlp.addIntent "explain_the_rules", []
  rulesNlp.addDocument "Does #{robot.name} know the rules?", "explain_the_rules"
  rulesNlp.addDocument "#{robot.name} what are the rules?", "explain_the_rules"
  rulesNlp.addDocument "@#{robot.name} what are the rules?", "explain_the_rules"
  rulesNlp.addDocument "does hubot know the laws of rules of robotics", "explain_the_rules"
  rulesNlp.addDocument "does hubot know the three laws of rules of robotics", "explain_the_rules"
  rulesNlp.addDocument "does hubot know the 3 laws of rules of robotics", "explain_the_rules"
  rulesNlp.addDocument "has hubot read the Robot series?", "explain_the_rules"
  rulesNlp.addDocument "does hubot read Asimov?", "explain_the_rules"

  robot.listen(
    (message) ->
      return unless message.text

      result = rulesNlp.test(message.text)
      console.log inspect result

      return unless result.intent is "explain_the_rules"

      # we only train for one specific intent. that means we only care when it is _reallly_ highly scored
      result.score > 0.999
    (response) ->
      response.send rules.join('\n')
  )

