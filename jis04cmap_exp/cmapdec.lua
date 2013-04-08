local line, fh -- line, file handler
local tt       -- 作業用 table

local function load_cid_char()
   local cid, ucs, ucsa
   line = fh:read("*l")
   while line do
      if string.find(line, "end...?char") then 
	 line = fh:read("*l"); return
      else -- WMA l is in the form "<%x+>%s%d+"
	 ucs, cid = string.match(line, "<(%x+)>%s+<?(%x+)>?")
	 cid = tonumber(cid); ucs = tonumber(ucs, 16); 
	 tt[ucs] = cid
      end
      line = fh:read("*l")
   end
end

local function load_cid_range()
   local bucs, eucs, cid
   line = fh:read("*l")
   while line do
        if string.find(line, "end...?range") then 
	   line = fh:read("*l"); return
	else -- WMA l is in the form "<%x+>%s+<%x+>"
	   bucs, eucs, cid = string.match(line, "<(%x+)>%s+<(%x+)>%s+<?(%x+)>?")
	   cid = tonumber(cid); 
	   bucs = tonumber(bucs, 16); eucs = tonumber(eucs, 16)
	   for ucs = bucs, eucs do
	      tt[ucs], cid = cid, cid + 1
	   end
	end
	line = fh:read("*l")
     end
  end

local function open_cmap_file(cmap_name, out_table)
   fh = io.open(kpse.find_file(cmap_name, 'cmap files'), "r")
   if not out_table then tt = {} else tt = out_table end
   line = fh:read("*l")
   while line do
      if string.find(line, "%x+%s+begin...?char") then
	 load_cid_char()
      elseif string.find(line, "%x+%s+begin...?range") then
	 load_cid_range()
      else
	 line = fh:read("*l")
      end
   end
   fh:close(); 
   return tt
end

return { open_cmap_file = open_cmap_file };