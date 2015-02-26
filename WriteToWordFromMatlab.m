function WriteToWordFromMatlab(path,rootTree)
% -------------------------------------------------------------------
% File: WriteToWordFromMatlab
% Descr:  This is an example of how to control MS-Word from Matlab.
%         With the subfunctions below it is simple to automatically
%         let Matlab create reports in MS-Word.
%         This example copies two Matlab figures into MS-Word, writes
%         some text and inserts a table.
%         Works with MS-Word 2003 at least.
% Created: 2005-11-22 Andreas Karlsson
% History:
% 051122  AK  Modification of 'save2word' in Mathworks File Exchange   
% 060204  AK  Updated with WordSymbol, WordCreateTable and "Flying Start" section 
% 060214  AK  Pagenumber, font color and TOC added

% 130115  Kristian Johansson Removed most stuff and made changes to fit our purposes
% -------------------------------------------------------------------
    
    if exist(path,'file')
       delete(path); 
    end
    
	[ActXWord,WordHandle]=StartWord(path);
    
    fprintf('Document will be saved in %s\n',path);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%Section 1
    %%create header in word        
     %NOTE! if you are NOT using an English version of MSWord you get
    % an error here. For Swedish installations use 'Rubrik 1'.    
    while rootTree.hasChildren()
        
        date_ = rootTree.popChild();
        
        Style='Heading 1';
        TextString=date_.getName();
        WordText(ActXWord,TextString,Style,[0,1]);%two enters after text
    
        %%Iterate through the foldertree, see documentation for FolderTree
        while date_.hasChildren()
            %Fetch and remove first child
            flower = date_.popChild();
            
            
            
            while flower.hasChildren()
                negOrPos = flower.popChild();
                Style='Heading 3';
                TextString= [flower.getName(),' - ',negOrPos.getName()];
                WordText(ActXWord,TextString,Style,[0,0]);
                
                while negOrPos.hasChildren()
                    
                    id = negOrPos.popChild();
                    
                    Style='No spacing';
                    TextString=id.getName();    
                    WordText(ActXWord,TextString,Style,[1,1]);
                    
                    while id.hasChildren()
                        8
                        type = id.popChild();
                        
                        first = true;
                        
                        while type.hasChildren()
                            if first
                                TextString=['      ',type.getName(),': '];    
                                WordText(ActXWord,TextString,Style,[0,0]);
                                first = false;
                            end
                            file_ = type.popChild();
                            
                            TextString=[file_.getName(),' '];    
                            WordText(ActXWord,TextString,Style,[0,0]);
                            
                            if ~type.hasChildren()
                                TextString='';    
                                WordText(ActXWord,TextString,Style,[0,1]);
                            end
                        end                        
                    end
                end                
            end            
        end        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    %Last thing is to replace the Table of Contents so all headings are
    %included.
    %Selection.GoTo What:=wdGoToField, Which:=wdGoToPrevious, Count:=1, Name:= "TOC"
    WordGoTo(ActXWord,7,3,1,'TOC',1);%%last 1 to delete the object
    %WordCreateTOC(ActXWord,1,3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    CloseWord(ActXWord,WordHandle,path);    
    %close all;
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUB-FUNCTIONS
% Creator Andreas Karlsson; andreas_k_se@yahoo.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [actx_word,word_handle]=StartWord(word_file_p)
    % Start an ActiveX session with Word:
    actx_word = actxserver('Word.Application');
    actx_word.Visible = true;
    trace(actx_word.Visible);  
    if ~exist(word_file_p,'file');
        % Create new document:
        word_handle = invoke(actx_word.Documents,'Add');
    else
        % Open existing document:
        word_handle = invoke(actx_word.Documents,'Open',word_file_p);
    end           
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function WordGoTo(actx_word_p,what_p,which_p,count_p,name_p,delete_p)
    %Selection.GoTo(What,Which,Count,Name)
    actx_word_p.Selection.GoTo(what_p,which_p,count_p,name_p);
    if(delete_p)
        actx_word_p.Selection.Delete;
    end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function WordCreateTOC(actx_word_p,upper_heading_p,lower_heading_p)
%      With ActiveDocument
%         .TablesOfContents.Add Range:=Selection.Range, RightAlignPageNumbers:= _
%             True, UseHeadingStyles:=True, UpperHeadingLevel:=1, _
%             LowerHeadingLevel:=3, IncludePageNumbers:=True, AddedStyles:="", _
%             UseHyperlinks:=True, HidePageNumbersInWeb:=True, UseOutlineLevels:= _
%             True
%         .TablesOfContents(1).TabLeader = wdTabLeaderDots
%         .TablesOfContents.Format = wdIndexIndent
%     End With
    actx_word_p.ActiveDocument.TablesOfContents.Add(actx_word_p.Selection.Range,1,...
        upper_heading_p,lower_heading_p);
    
    actx_word_p.Selection.TypeParagraph; %enter  
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function WordText(actx_word_p,text_p,style_p,enters_p,color_p)
	%VB Macro
	%Selection.TypeText Text:="Test!"
	%in Matlab
	%set(word.Selection,'Text','test');
	%this also works
	%word.Selection.TypeText('This is a test');    
    if(enters_p(1))
        actx_word_p.Selection.TypeParagraph; %enter
    end
	actx_word_p.Selection.Style = style_p;
    if(nargin == 5)%check to see if color_p is defined
        actx_word_p.Selection.Font.Color=color_p;     
    end
    
	actx_word_p.Selection.TypeText(text_p);
    %actx_word_p.Selection.Font.Color='wdColorAutomatic';%set back to default color
    for k=1:enters_p(2)    
        actx_word_p.Selection.TypeParagraph; %enter
    end
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function WordSymbol(actx_word_p,symbol_int_p)
    % symbol_int_p holds an integer representing a symbol, 
    % the integer can be found in MSWord's insert->symbol window    
    % 176 = degree symbol
    actx_word_p.Selection.InsertSymbol(symbol_int_p);
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function WordCreateTable(actx_word_p,nr_rows_p,nr_cols_p,data_cell_p,enter_p) 
    %Add a table which auto fits cell's size to contents
    if(enter_p(1))
        actx_word_p.Selection.TypeParagraph; %enter
    end
    %create the table
    %Add = handle Add(handle, handle, int32, int32, Variant(Optional))
    actx_word_p.ActiveDocument.Tables.Add(actx_word_p.Selection.Range,nr_rows_p,nr_cols_p,1,1);
    %Hard-coded optionals                     
    %first 1 same as DefaultTableBehavior:=wdWord9TableBehavior
    %last  1 same as AutoFitBehavior:= wdAutoFitContent
     
    %write the data into the table
    for r=1:nr_rows_p
        for c=1:nr_cols_p
            %write data into current cell
            WordText(actx_word_p,data_cell_p{r,c},'Normal',[0,0]);
            
            if(r*c==nr_rows_p*nr_cols_p)
                %we are done, leave the table
                actx_word_p.Selection.MoveDown;
            else%move on to next cell 
                actx_word_p.Selection.MoveRight;
            end            
        end
    end
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function WordPageNumbers(actx_word_p,align_p)
    %make sure the window isn't split
    if (~strcmp(actx_word_p.ActiveWindow.View.SplitSpecial,'wdPaneNone')) 
        actx_word_p.Panes(2).Close;
    end
    %make sure we are in printview
    if (strcmp(actx_word_p.ActiveWindow.ActivePane.View.Type,'wdNormalView') | ...
        strcmp(actx_word_p.ActiveWindow.ActivePane.View.Type,'wdOutlineView'))
        actx_word_p.ActiveWindow.ActivePane.View.Type ='wdPrintView';
    end
    %view the headers-footers
    actx_word_p.ActiveWindow.ActivePane.View.SeekView='wdSeekCurrentPageHeader';
    if actx_word_p.Selection.HeaderFooter.IsHeader
        actx_word_p.ActiveWindow.ActivePane.View.SeekView='wdSeekCurrentPageFooter';
    else
        actx_word_p.ActiveWindow.ActivePane.View.SeekView='wdSeekCurrentPageHeader';
    end
    %now add the pagenumbers 0->don't display any pagenumber on first page
     actx_word_p.Selection.HeaderFooter.PageNumbers.Add(align_p,0);
     actx_word_p.ActiveWindow.ActivePane.View.SeekView='wdSeekMainDocument';
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PrintMethods(actx_word_p,category_p)
    style='Heading 3';
    text=strcat(category_p,'-methods');
    WordText(actx_word_p,text,style,[1,1]);           
    
    style='Normal';    
    text=strcat('Methods called from Matlab as: ActXWord.',category_p,'.MethodName(xxx)');
    WordText(actx_word_p,text,style,[0,0]);           
    text='Ignore the first parameter "handle". ';
    WordText(actx_word_p,text,style,[1,3]);           
    
    MethodsStruct=eval(['invoke(actx_word_p.' category_p ')']);
    MethodsCell=struct2cell(MethodsStruct);
    NrOfFcns=length(MethodsCell);
    for i=1:NrOfFcns
        MethodString=MethodsCell{i};
        WordText(actx_word_p,MethodString,style,[0,1]);           
    end
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function FigureIntoWord(actx_word_p)
	% Capture current figure/model into clipboard:
	print -dmeta
	% Find end of document and make it the insertion point:
	end_of_doc = get(actx_word_p.activedocument.content,'end');
	set(actx_word_p.application.selection,'Start',end_of_doc);
	set(actx_word_p.application.selection,'End',end_of_doc);
	% Paste the contents of the Clipboard:
    %also works Paste(ActXWord.Selection)
	invoke(actx_word_p.Selection,'Paste');
    actx_word_p.Selection.TypeParagraph; %enter    
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CloseWord(actx_word_p,word_handle_p,word_file_p)
    if ~exist(word_file_p,'file')
        % Save file as new:
        invoke(word_handle_p,'SaveAs',word_file_p,1);
    else
        % Save existing file:
        invoke(word_handle_p,'Save');
    end
    % Close the word window:
    invoke(word_handle_p,'Close');            
    % Quit MS Word
    invoke(actx_word_p,'Quit');            
    % Close Word and terminate ActiveX:
    delete(actx_word_p);            
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%