(* edMouse (c)2024 Marc Dendooven *)

program edMouse;

	const eol=#10;
	      stackSize=10;  
	var p: array of char; // program space
		programSize: cardinal;
		i: cardinal; // index in program (current char is p[i] )
		s: array[0..stackSize-1] of integer; 
		sp: cardinal = 0; // stackpointer
		vars: array['A'..'Z'] of integer;
		v: integer;
		ch: char;
		
	procedure error(er: string);
	begin
		writeln('ERROR: ',er);
		halt
	end;
		
	procedure loadProgram;
		var F: file of char;
	begin
		if paramCount=0 then error('Filename expected');
		{$i-}
		assign (F,paramStr(1));
		reset(F);
		{$i+}
		if IOresult<>0 then error('File does not exist');
		programSize := fileSize(F);
		setLength(p,programSize);
		for i := 0 to programSize-1 do read(F,p[i]);
		close(F);
	end;
	
	procedure push(val: integer);
	begin
		if sp>=stackSize then error('stack overflow');
		s[sp]:=val;
		inc(sp)
	end;
	
	function pop: integer;
	begin
		if sp<=0 then error('stack underflow');
		dec(sp); 
		pop:=s[sp]
	end;

	procedure text;
	begin
		inc(i);
		while p[i]<>'"' do 
			begin 
				if p[i]='!' then writeln
							else write(p[i]);
				inc(i)
			end;
//		inc(i)
	end;
	
	function number: cardinal;
	begin
		number:=0;
		while p[i] in ['0'..'9'] do
		begin
			number := 10*number+ord(p[i])-ord('0');
			inc(i)
		end;
	end;
	
	procedure closeloop;
		var hl: integer = 0;
	begin
		repeat
			if p[i]=')' then inc(hl);
			if p[i]='(' then dec(hl);
			dec(i)
		until hl=0;
		inc(i)
	end;
	
begin
	writeln('+------------------------+');
	writeln('|   Welcome to edMouse   |');
	writeln('| (c)2024 Marc Dendooven |');
	writeln('+------------------------+');

	loadProgram;
//	for i := 0 to programSize-1 do write(p[i]);
	
	i := 0;
	repeat
	//	write(prog[pc]);
		case p[i] of
			eol: ;
			' ': ;
			'~': while p[i]<>eol do inc(i);
			'"': text;
			'0'..'9': push(number);
			'A'..'Z': push(ord(p[i]));
			':': begin v:=pop; vars[char(v)]:=pop end;
			'.': push(vars[char(pop)]);
			'!': if p[i+1]='''' then begin write(chr(pop));inc(i) end
								else write(pop);
			'?': if p[i+1]='''' 
					then begin readln(ch);push(ord(ch));inc(i) end
					else begin readln(v);push(v) end;
			'+': push(pop+pop);
			'*': push(pop*pop);
			'-': begin v:=pop;push(pop-v) end;
			'/': begin v:=pop;push(pop div v) end;
			'\': begin v:=pop;push(pop mod v) end;
			'>': begin v:=pop;push(smallint(pop>v)) end;
			'<': begin v:=pop;push(smallint(pop<v)) end;			
			'=': begin v:=pop;push(smallint(pop=v)) end;
			'[': if pop=0 then while p[i]<>']' do inc(i);
			']': ;
			'(': ; 
			'^': if pop=0 then while p[i]<>')' do inc(i);
			')': closeloop;
			'$': begin writeln; writeln; writeln('bye');halt end
			else error('unknown character '+p[i])
		end;
		inc(i)
	until false
end. 
