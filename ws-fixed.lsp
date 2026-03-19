(defun c:WS ( / acApp acDoc ms basept txt h styleName ts sty mt acCol)

  (vl-load-com)

  ;; 1) 强制中断所有可能的命令，避免 LT 卡住
  (while (> (getvar "CMDACTIVE") 0)
    (command "")
  )

  ;; 2) 获取 AutoCAD ActiveX 对象
  (setq acApp (vlax-get-Acad-Object))
  (setq acDoc (vla-get-ActiveDocument acApp))
  (setq ms   (vla-get-ModelSpace acDoc))

  ;; 3) 固定文字和高度
  (setq txt "Working Space")
  (setq h   3.2)

  ;; 4) 确保 Arial 字体样式 WS_ARIAL 存在
  (setq styleName "WS_ARIAL")
  (setq ts (vla-get-TextStyles acDoc))
  (setq sty (vl-catch-all-apply 'vla-Item (list ts styleName)))

  ;; 如果没有这个样式 → 创建它
  (if (vl-catch-all-error-p sty)
      (setq sty (vla-Add ts styleName))
  )

  ;; 设置字体为 Arial
  (vla-SetFont sty "Arial" :vlax-false :vlax-false 0 0)

  ;; 5) 获取放置点
  (setq basept (getpoint "\n请选择放置位置: "))

  ;; 如果用户取消点选
  (if (not basept)
    (progn (princ "\n已取消。") (exit))
  )

  ;; 6) 开始 AutoCAD Undo 块
  (vla-StartUndoMark acDoc)

  ;; 7) 使用 ActiveX 创建 MText（LT 稳定方法）
  (setq mt (vla-AddMText ms (vlax-3D-point basept) 200 txt))

  (if (not mt)
    (progn
      (princ "\n⚠ MText 创建失败。请换一个点再试。")
      (vla-EndUndoMark acDoc)
      (exit)
    )
  )

  ;; 8) 设置样式、高度、对齐方式
  (vla-put-StyleName mt styleName)
  (vla-put-Height    mt h)
  (vla-put-AttachmentPoint mt 5) ;; Middle Center

  ;; 9) 背景遮罩颜色设置为 ACI 90
  (vla-put-BackgroundFill mt :vlax-true)
  (setq acCol (vlax-create-object "AutoCAD.AcCmColor"))
  (vla-put-ColorIndex acCol 90)
  (vla-put-BackgroundFillColor mt acCol)
  (vlax-release-object acCol)

  ;; 10) 结束 Undo 块
  (vla-EndUndoMark acDoc)

  (princ "\n✔ Working Space 已创建（Arial / 高3.2 / 背景色90）。")
  (princ)
)
