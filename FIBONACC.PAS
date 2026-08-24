{ fibonacci.pas - port of https://github.com/minusfortynine/fibonacci/blob/master/fibonacci.c
  Turbo Pascal 5.5 / MS-DOS
  Computes Fibonacci(n) for 0 <= n <= 93 using simulated unsigned 64-bit arithmetic. }

program Fibonacci;

type
  { Little-endian unsigned 64-bit: [0] = least significant Word }
  TUint64 = array[0..3] of Word;

{ ---------- helpers for TUint64 ---------- }

procedure SetZero(var u: TUint64);
var
  i: Integer;
begin
  for i := 0 to 3 do
    u[i] := 0;
end;

procedure SetOne(var u: TUint64);
begin
  SetZero(u);
  u[0] := 1;
end;

function IsZero(u: TUint64): Boolean;
begin
  IsZero := (u[0] = 0) and (u[1] = 0) and
            (u[2] = 0) and (u[3] = 0);
end;

{ Add a + b into result. Returns True if no overflow (final carry = 0). }
function AddUInt64(a, b: TUint64; var result: TUint64): Boolean;
var
  i: Integer;
  sum, carry: LongInt;
begin
  carry := 0;
  for i:= 0 to 3 do
  begin
    sum := LongInt(a[i]) + LongInt(b[i]) + carry;
    result[i] := Word(sum and $FFFF);
    carry := sum shr 16;
  end;
  AddUInt64 := (carry = 0);
end;

{ Divide num by 10 in place; return reminder 0..9 }
procedure DivMod10(var num: TUint64; var rem: Word);
var
  i: Integer;
  temp: LongInt;
begin
  rem := 0;
  for i := 3 downto 0 do
  begin
    temp := LongInt(rem) * 65536 + LongInt(num[i]);
    num[i] := Word(temp div 10);
    rem := Word(temp mod 10);
  end;
end;

function UInt64ToStr(n: TUint64): string;
var
  s: string;
  r: Word;
  temp: TUint64;
begin
  if IsZero(n) then
  begin
    UInt64ToStr := '0';
    Exit;
  end;
  s := '';
  temp := n;
  while not IsZero(temp) do
  begin
    DivMod10(temp, r);
    s := Chr(Ord('0') + r) + s;
  end;
  UInt64ToStr := s;
end;

{ ---------- Fibonacci ---------- }

procedure ComputeFibonacci(n: LongInt; var result: TUint64);
var
  prev, curr, next: TUint64;
  i: LongInt;
begin
  if n = 0 then
  begin
    SetZero(result);
    Exit;
  end;
  if n = 1 then
  begin
    SetOne(result);
    Exit;
  end;

  SetZero(prev);
  SetOne(curr);
  i := 2;

  while i <= n do
  begin
    if not AddUInt64(prev, curr, next) then
    begin
      WriteLn('Internal overflow while computing Fibonacci.');
      Halt(1);
    end;
    prev := curr;
    curr := next;
    Inc(i);
  end;

  result := curr;
end;

{ ---------- main ---------- }

var
  n: LongInt;
  fib: TUint64;
begin
  Write('Enter a non-negative intege n to compute the nth Fibonacci number (0-93 recommended): ');
  ReadLn(n);

  if (n < 0) or (n > 93) then
  begin
    if n < 0 then
      WriteLn('Invalid input (negative). Exiting.')
    else
      WriteLn('n too large: overflow in uint64 beyond 93. Exiting.');
    Halt(1);
  end;

  ComputeFibonacci(n, fib);
  WriteLn('Fibonacci(', n, ') = ', UInt64ToStr(fib));
end.