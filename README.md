# hubot-for-hubot

hubot-for-hubot is a chat bot built on the [Hubot](https://hubot.github.com) framework for helping the [Hubot community on Slack](https://hubot-slackin.herokuapp.com/). Hubot. Hubot? Hubot!

### Running hubot Locally

You can run hubot-for-hubot by running the following, however some plugins will not
behave as expected unless the [environment variables](#configuration) they rely
upon have been set.

    % bin/hubot

You'll see some start up output and a prompt:

    [Sat Feb 28 2015 12:38:27 GMT+0000 (GMT)] INFO Using default redis on localhost:6379
    hubot>

Then you can interact with hubot by typing `hubot help`.

    hubot> hubot help
    hubot animate me <query> - The same thing as `image me`, except adds [snip]
    hubot help - Displays all of the help commands that hubot knows about.
    ...

### Scripting

See `scripts` and `external-scripts`. See [Scripting Guide][scripting-docs] for
documentation on writing scripts in general.

For many common tasks, there's a a chance someone has already written one and
published to [npm](https://www.npmjs.com/search?q=hubot) already.

[scripting-docs]: https://github.com/github/hubot/blob/master/docs/scripting.md

## Deployment

The hubot-for-hubot deployment is managed by the @hubotio/hubot-for-hubot-operators team. The Heroku application is hubot-for-hubot. It's using [redistogo](https://elements.heroku.com/addons/redistogo) for persistence.

To get running, you can use:

    % bin/setup-heroku

You'll be able to use the normal Heroku commands after that. In particular, to deploy:

    % git push heroku master

### Restart the bot

You may want to get comfortable with `heroku logs` and `heroku restart` if
you're having issues.
