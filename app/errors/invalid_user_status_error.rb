class InvalidUserStatusError < StandardError
  # 無効なステータス値を読み取るためのリーダーを定義
  attr_reader :invalid_status

  # 慣例として、エラーメッセージと無効なステータス値を受け取るようにします。
  def initialize(invalid_status:, message: "Invalid user status specified")
    # super() で StandardError のコンストラクタを呼び出し、
    # その際に表示したいエラーメッセージを渡します。
    super("#{message}: {invalid_status: \"#{invalid_status}\"}")

    # エラーオブジェクト自身に無効なステータス値を保持させます。
    @invalid_status = invalid_status
  end
end
