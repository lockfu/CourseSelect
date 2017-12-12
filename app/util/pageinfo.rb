class PageInfo

	attr_accessor :currentPage,:pageSize,:recordCount,:records,:pageCount,:beginPageIndex,:eendPageIndex,:cids

	def initialize(currentPage,pageSize,recordCount,records,cids)
		@currentPage = currentPage
		@pageSize = pageSize
		@recordCount = recordCount
		@records = records
		@cids = cids

		@pageCount = (recordCount + pageSize -1)/pageSize

		
	
		# if @pageCount <= 10
		# 	@beginPageIndex = 1
		# 	@eendPageIndex = @pageCount
		# else
		# 	@beginPageIndex = @currentPage -4
		# 	@eendPageIndex = @currentPage + 5
		# 	if @beginPageIndex < 1
		# 		@beginPageIndex = 1
		# 		@eendPageIndex = 10
		# 	end
		# 	if @eendPageIndex > @pageCount
		# 		@eendPageIndex = @pageCount
		# 		@beginPageIndex = @pageCount - 10 + 1		
		# 	end	
		# end


		if @pageCount <= 4
			@beginPageIndex = 1
			@eendPageIndex = @pageCount
		else
			@beginPageIndex = @currentPage -1
			@eendPageIndex = @currentPage + 2
			if @beginPageIndex < 1
				@beginPageIndex = 1
				@eendPageIndex = 4
			end
			if @eendPageIndex > @pageCount
				@eendPageIndex = @pageCount
				@beginPageIndex = @pageCount - 4 + 1		
			end	
		end

	end


	def currentPage    #当前页
		@currentPage
	end
	def currentPage=(currentPage)    
		@currentPage = currentPage
	end

	def pageSize    # 每页记录数
		@pageSize
	end
	def pageSize=(pageSize)    
		@pageSize = pageSize
	end

	def recordCount   #总的记录数
		@recordCount
	end
	def recordCount=(recordCount)    
		@recordCount = recordCount
	end

	def records    # 记录变量
		@records
	end
	def records=(records)    
		@records = records
	end

	def pageCount    # 总页数
		@pageCount
	end
	def pageCount=(pageCount)    
		@pageCount = pageCount
	end

	def beginPageIndex    # 开始索引
		@beginPageIndex
	end
	def beginPageIndex=(beginPageIndex)    
		@beginPageIndex = beginPageIndex
	end

	def eendPageIndex    # 结束索引
		@eendPageIndex
	end
	def endPageIndex=(eendPageIndex)    
		@eendPageIndex = eendPageIndex
	end

	def cids   
		@cids
	end
	def cids=(cids)    
		@cids = cids
	end

	
end