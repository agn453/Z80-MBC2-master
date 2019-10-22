program lc;
var inpnam, outnam: string[16]; {* input and output filenames *}
    inf, outf: text;
    buf: string[255];
    i, j, k: integer;
    l: boolean;
begin
  if paramcount = 0 then begin
    writeln('Usage: LC filename (default extension .MAC)');writeln;
    writeln('Reformats an assembly language source file to lowercase');
    halt; end;
  inpnam := paramstr(1);
  i := pos('.',inpnam); if i = 0 then inpnam := inpnam+'.MAC';
  outnam := inpnam;
  i := pos('.',outnam);
  for j:=i+1 to i+3 do outnam[j] := 'L'; outnam[i+4] := char(0);
  writeln( 'Processing ', inpnam, ' to ', outnam );
  assign(inf,inpnam); {$I-} reset(inf); {$I+}
  if ioresult <> 0 then begin
    writeln('Input file not found!'); halt; end;
  assign(outf,outnam); rewrite(outf);
  l := false;
  while not eof(inf) do begin
    readln(inf, buf);
    if length(buf) > 0 then begin
      j := length(buf); k :=  pos(';',buf); if k <> 0 then j := k;
      for i := 1 to j do begin
        if buf[i] = '''' then l := not l;
        k := ord(buf[i]);
        if not l then if (k >= ord('A')) and (k <= ord('Z')) then k := k+32;
        buf[i] := char(k); end;
      end;
    writeln(outf, buf); l := false; end;
  close(inf); close(outf);
  writeln('Done.');
  halt;
end.

