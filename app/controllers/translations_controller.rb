# -*- coding: utf-8 -*-

class TranslationsController < ApplicationController

  skip_before_action :verify_authenticity_token

  def viewer
    render :json => TEST_TRANSLATION, :callback => params[:callback]
  end

  TEST_TRANSLATION =  {
    "NoteBy"             => "附加说明：",
    "NoteTitle"          => "注释标题",
    "CLOSE"              => "关闭",
    "Cancel"             => "取消",
    "ClickAddPageNote"   => "点击添加一个页面注意",
    "Contents"           => "内容",
    "ContributedBy"      => "提供者：",
    "Delete"             => "删除",
    "Description"        => "描述",
    "Document"           => "文件",
    "DViewerContNoFound" => "文档查看器的容器元素未找到：",
    "DLAsPDF"            => "下载本文档为PDF",
    "Draft"              => "草案",
    "Expand"             => "扩大",
    "LinkToNote"         => "这说明",
    "Loading"            => "载入中",
    "Next"               => "下",
    "NextNote"           => "下一个注解",
    "Note"               => "注意",
    "Notes"              => "笔记",
    "NoPrintPDFWithNote" => "要打印的文档，单击“原始文件”链接，打开原始的PDF。在这个时候，它是不可能的打印文档与注释",
    "Page"               => "页",
    "Pages"              => "页",
    "Previous"           => "前",
    "PreviousNotetation" => "上一页注释",
    "PrintNotes"         => "打印票据",
    "PrivateNote"        => "私人笔记",
    "Publish"            => "发布",
    "RelatedArticle"     => "相关文章",
    "Save"               => "保存",
    "SaveAsDraft"        => "保存为草稿",
    "Search"             => "搜索",
    "Text"               => "文本",
    "DraftOnlyVisCollab" => "该草案是唯一可见的给你和合作者。",
    "PrivateNoteVisSelf" => "这家私人值得注意的是只有你自己可见。",
    "NeedToUpgrade"      => "使用文档浏览器，您需要升级您的浏览器：",
    "ToggleDesc"         => "切换说明",
    "UntitledNote"       => "无题注",
    "ViewFullscreen"     => "在全屏查看文件",
    "Zoom"               => "放大",
    "for"                => "为",
    'ContinueIE6'        => "或者，如果你想继续使用Internet Explorer 6，您可以",
    "installChromeFrame" => "安装谷歌Chrome Frame",
    "LookupWOutID"       => "看着没有ID的注释",
    "p"                  => "页。",
    'of'                 => '的'
  }

end
