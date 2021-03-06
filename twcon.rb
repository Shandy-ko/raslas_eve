# coding:utf-8
require 'yaml'
require 'twitter'
require 'tweetstream'
require 'docomoru'

class Eve
  # 外部から参照できるメンバ変数
  attr_accessor :client, :timeline

  def initialize
    keys=YAML.load_file('./config.yml')

    # restAPI初期化
    @client=Twitter::REST::Client.new{|config|
      config.consumer_key=keys["api_key"]
      config.consumer_secret=keys["api_secret"]
      config.access_token=keys["access_token"]
      config.access_token_secret=keys["access_token_secret"]
    }

    # StreamAPI初期化
    TweetStream.configure{|config|
      config.consumer_key=keys["api_key"]
      config.consumer_secret=keys["api_secret"]
      config.oauth_token=keys["access_token"]
      config.oauth_token_secret=keys["access_token_secret"]
      config.auth_method=:oauth
    }
    @timeline=TweetStream::Client.new

    # docmoAPI初期化
    @docomoru=Docomoru::Client.new(api_key: keys["docomo_api_key"])
  end

  # 引数を投稿するメソッド
  def say(words, id)
    @client.update(words, :in_reply_to_status_id => id)
  end

  # 会話を生成する
  def docomoru_create_dialogue(str)
    response=@docomoru.create_dialogue(str)
    return response.body["utt"]
  end

  # QandA
  def docomoru_create_knowledge(str)
    response=@docomoru.create_knowledge(str)
    if(response.body["code"]=="E020010")
      return response.body["message"]["textForDisplay"]
    else
      if(response.body["answers"][0]["linkUrl"]==nil)
        return response.body["message"]["textForDisplay"]
      else
        return response.body["message"]["textForDisplay"]+"<"+response.body["answers"][0]["linkUrl"]+">"
      end
    end
  end

  # 画像をランダムで投稿するメソッド
  def iyashi(words, imgloc, id)
    img=open(imgloc)
    @client.update_with_media(words,img, :in_reply_to_status_id => id)
  end
end
