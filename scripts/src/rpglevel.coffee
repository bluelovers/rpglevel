do () ->

  # @TODO 定型のExpテーブルを用意
  # @TODO MaxExpを超過した獲得経験値を切り捨てるか保持するかのオプション

  class RPGLevel

    @VERSION = '0.0.1'

    @InvalidArgsError = class InvalidArgsError extends Error
      constructor: (@message) ->
        @name = 'InvalidArgsError'
        super

    constructor: () ->

      @_exp = 0

      # This is necessary-Exp delta list for Level-Up.
      # For example, [0, 2, 4, 8] means what
      #   it needs total Exps [Lv1=0, Lv2=2, Lv3=6, Lv4=14].
      # For that reason, [0] is always to contain 0.
      @_necessaryExps = []

      @_minLevel = 1

      @_cachedExp = @_exp
      @_cachedLevelInfo = null

    defineExpTable: (args...) ->
      if args[0] instanceof Array
        @_necessaryExps = args[0]
      else
        @_necessaryExps = @_generateNecessaryExps(args[0], args[1])

      if @_necessaryExps[0] isnt 0
        throw new InvalidArgsError "Invalid Exp-Table."

    _generateNecessaryExps: (formula, options={}) ->
      opts =
        startLevel: 1
        maxLevel: 99
      opts[k] = v for k, v of options

      @_necessaryExps = for level in [@_minLevel..opts.maxLevel]
        if level <= opts.startLevel
          0
        else
          formula(level, {
            minLevel: @_minLevel
            startLevel: opts.startLevel
            maxLevel: opts.maxLevel
          })

    getMinLevel: -> @_minLevel

    getMaxLevel: ->
      @_necessaryExps.length

    getStartLevel: ->
      for i, v of @_necessaryExps
        return parseInt(i, 10) if v > 0

    _getIndexByLevel: (level) ->
      level - 1

    getExp: -> @_exp

    getTotalNecessaryExp: (fromLevel, toLevel) ->
      total = 0
      for level in [(fromLevel + 1)..toLevel]
        idx = @_getIndexByLevel(level)
        total += @_necessaryExps[idx]
      total

    getMaxExp: ->
      @getTotalNecessaryExp(@getMinLevel(), @getMaxLevel())


  # Exports
  if typeof module isnt 'undefined'
    module.exports = RPGLevel
  else
    window.RPGLevel = RPGLevel


#    /** 現LVと経験値についての情報を返す
#        一緒に色々返すのは処理がわずかに重い＋複雑だから
#        @return [<現LV>, <次LVへの繰り越し経験値||null>, <次LVに必要な経験値全体||null>]
#                nullはレベルが上限に達していることを示す */
#    kls.prototype.getLvInfo = function(){
#        var self = this;
#        // 前評価時と同じ場合はキャッシュから返す
#        if (this._cachedLvInfo !== null && this._exp === this._cachedExp) {
#            return this._cachedLvInfo.slice();
#        };
#        var yourLv = 0;
#        var totalNecessaryExp = 0;
#        var nextLvFullExp = null;
#        var nextLvCurrentExp = null;
#        $f.each(this._necessaryExps, function(i, necessaryExp){
#            var nextLv = i + 1;
#            totalNecessaryExp += necessaryExp;
#            if (self._exp >= totalNecessaryExp) {
#                yourLv = nextLv;
#            } else {
#                nextLvFullExp = necessaryExp;
#                nextLvCurrentExp = self._exp - (totalNecessaryExp - necessaryExp);
#                return false;
#            };
#        });
#        if (yourLv === 0) {// 一応, 通らないはず
#            throw new Error('RPGMaterial:LvManager.getLvInfo, invalid situation');
#        };
#        var lvInfo = [yourLv, nextLvCurrentExp, nextLvFullExp];
#        // キャッシュ情報更新
#        if (this._exp !== this._cachedExp) {
#            this._cachedExp = this._exp;
#            this._cachedLvInfo = lvInfo.slice();
#        };
#        return lvInfo;
#    };
#
#    /** 現LVのみを返す */
#    kls.prototype.getLv = function(){
#        return this.getLvInfo()[0];
#    };
#
#    /** 経験値を得る, @return false=LVUPしなかった arr=LVUPした場合にその情報 */
#    kls.prototype.gainExp = function(exp, withNews){
#        var withNews = !!withNews;
#        var before = this.getLvInfo();
#        this._exp = $f.withinNum(this._exp + exp, null, this.getExpCap());
#        var after = this.getLvInfo();
#        if (before[0] < after[0]) { return after };
#        return false;
#    };
#
#    /** 現LVから上昇するLV分の経験値を得る
#        余ってた経験値は繰り越される, @return 同gainExp */
#    kls.prototype.gainExpByLv = function(lvCount){
#        var fromLv = this.getLv();
#        var toLv = fromLv + lvCount;
#        toLv = $f.withinNum(toLv, null, this.getLvCap());
#        return this.gainExp(this.calculateTotalNecessaryExp(fromLv, toLv));
#    };
#
#    /** LV計算で経験値を下げる, 端数は切り捨てられてそのLV内での最低値になる */
#    kls.prototype.drainExpByLv = function(lvCount){
#        var toLv = $f.withinNum(this.getLv() - lvCount, 1);
#        this._exp = this.calculateTotalNecessaryExp(1, toLv);
#    };
