;;; ------------------------------------------------------------
;;; Command: YPL
;;; 功能：
;;;   ① 由 P1、P2 创建第一条正交 polyline（宽 0.6）
;;;   ② 从 P2O 出发，再创建第二条 polyline（长度 4.48，宽 2，颜色 RGB:255,255,0）
;;;      第二条线的方向由第三、第四个点决定（但起点固定为 P2O）
;;; ------------------------------------------------------------

(defun _round-to-ortho (p1 p2 / dx dy z)
  ;; 将 p2 投影到相对 p1 最近的水平或垂直方向（保持 p1 的 Z）
  (setq dx (- (car p2)  (car p1))
        dy (- (cadr p2) (cadr p1))
        z  (if (numberp (caddr p1)) (caddr p1) 0.0))
  (if (>= (abs dx) (abs dy))
    (list (car p2) (cadr p1) z)
    (list (car p1) (cadr p2) z)
  )
)

(defun _sgn (x)
  (cond ((< x 0.0) -1.0)
        ((> x 0.0)  1.0)
        (t          1.0)))

(defun c:YPL ( / *error* oldEcho oldOrtho oldCol
                p1 p2 p2o dx dy z
                p3 p4 dx2 dy2 dir
                len2 pEnd)

  (vl-load-com)

  ;; 错误恢复
  (defun *error* (msg)
    (if oldEcho  (setvar 'CMDECHO   oldEcho))
    (if oldOrtho (setvar 'ORTHOMODE oldOrtho))
    (if oldCol   (setvar 'CECOLOR   oldCol))
    (if (and msg (not (wcmatch (strcase msg) "*CANCEL*,*QUIT*")))
      (princ (strcat "\n出错: " msg))
    )
    (princ)
  )

  ;; 保存系统变量
  (setq oldEcho  (getvar 'CMDECHO)
        oldOrtho (getvar 'ORTHOMODE)
        oldCol   (getvar 'CECOLOR))
  (setvar 'CMDECHO 0)

  ;; 选择第一条线 P1、P2
  (setq p1 (getpoint "\nSelect the starting point of the first line.（P1）："))
  (setq p2 (getpoint p1 "\nSelect the second point on the first line.（P2）："))

  ;; 得到正交化第二点 P2O
  (setq p2o (_round-to-ortho p1 p2))
  (setq dx (- (car p2o) (car p1))
        dy (- (cadr p2o) (cadr p1))
        z  (if (numberp (caddr p1)) (caddr p1) 0.0))

  ;; 第一条线（示例使用 ACI=50）
  (setvar 'ORTHOMODE 0)
  (setvar 'CELTYPE "BYLAYER")
  (setvar 'CECOLOR "RGB:255,255,0")
  (command
    "_.PLINE" p1
    "_W" 0.6 0.6
    p2o
    "")

  ;; 获取 P3、P4 作为第二条线方向参考点
  (setq p3 (getpoint "\Choose the third point："))
  (setq p4 (getpoint p3 "\nChoose the fourth point.："))

  ;; 判断方向：水平 or 垂直
  (setq dx2 (- (car p4) (car p3))
        dy2 (- (cadr p4) (cadr p3)))

  ;; 第二条线长度固定
  (setq len2 4.48)

  ;; 根据方向构造终点
  (if (>= (abs dx2) (abs dy2))
    ;; 水平方向
    (setq pEnd (list (+ (car p2o) (* (_sgn dx2) len2))
                     (cadr p2o)
                     z))
    ;; 垂直方向
    (setq pEnd (list (car p2o)
                     (+ (cadr p2o) (* (_sgn dy2) len2))
                     z))
  )

  ;; 第二条线颜色 = RGB(255,255,0)
  (setvar 'CECOLOR "RGB:255,255,0")
  (setvar 'CELTYPE "BYLAYER")

  (command
    "_.PLINE" p2o
    "_W" 2 2
    pEnd
    "")



  ;; 恢复环境
  (setvar 'CECOLOR   oldCol)
  (setvar 'ORTHOMODE oldOrtho)
  (setvar 'CMDECHO   oldEcho)
  (setvar 'PLINEWID 0)

  (princ "\nFirst line: P1 → P2O has been created.Second line: starting from P2O, with a fixed length of 4.48, direction based on P3 → P4.")
  (princ)
)