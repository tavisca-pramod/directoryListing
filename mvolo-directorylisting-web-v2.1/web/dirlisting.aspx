<%@ Page Language="c#" %>
<%@ Import Namespace="Mvolo.DirectoryListing" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.IO" %>
<script runat="server">
void Page_Load()
{
    String path = null;
    String parentPath = null;
    int count = 0;
    String sortBy = Request.QueryString["sortby"];
    
    //
    // Databind to the directory listing
    //
    DirectoryListingEntryCollection listing = 
        Context.Items[DirectoryListingModule.DirectoryListingContextKey] as DirectoryListingEntryCollection;
    
    if (listing == null)
    {
        throw new Exception("This page cannot be used without the DirectoryListing module");
    }

    //
    // Handle sorting
    //
    if (!String.IsNullOrEmpty(sortBy))
    {
        if (sortBy.Equals("name"))
        {
            listing.Sort(DirectoryListingEntry.CompareFileNames);
        }
        else if (sortBy.Equals("namerev"))
        {
            listing.Sort(DirectoryListingEntry.CompareFileNamesReverse);
        }            
        else if (sortBy.Equals("date"))
        {
            listing.Sort(DirectoryListingEntry.CompareDatesModified);        
        }
        else if (sortBy.Equals("daterev"))
        {
            listing.Sort(DirectoryListingEntry.CompareDatesModifiedReverse);        
        }
        else if (sortBy.Equals("size"))
        {
            listing.Sort(DirectoryListingEntry.CompareFileSizes);
        }
        else if (sortBy.Equals("sizerev"))
        {
            listing.Sort(DirectoryListingEntry.CompareFileSizesReverse);
        }
    }

    DirectoryListing.DataSource = listing;
    DirectoryListing.DataBind();
        
    //
    //  Prepare the file counter label
    //
    FileCount.Text = listing.Count + " items.";

    //
    //
    //  Parepare the parent path label
    path = VirtualPathUtility.AppendTrailingSlash(Context.Request.Path);
    if (path.Equals("/") || path.Equals(VirtualPathUtility.AppendTrailingSlash(HttpRuntime.AppDomainAppVirtualPath)))
    {
        // cannot exit above the site root or application root
        parentPath = null;
    }
    else
    {
        parentPath = VirtualPathUtility.Combine(path, "..");
    }
    
    if (String.IsNullOrEmpty(parentPath))
    {
        NavigateUpLink.Visible = false;
        NavigateUpLink.Enabled = false;
    }
    else
    {
        NavigateUpLink.NavigateUrl = parentPath;
    }
}

String GetFileSizeString(FileSystemInfo info)
{
    if (info is FileInfo)
    {
        return String.Format("- {0}K", ((int)(((FileInfo)info).Length * 10 / (double)1024) / (double)10));
    }
    else
    {
        return String.Empty;
    }
}

 // Finds extensions of files
         string FindExtension(string filename) {
           filename = filename.ToLower();
             var extension = filename.Split('.');
             
             return null;
         }

         protected void DirectoryListing_SelectedIndexChanged(object sender, EventArgs e)
         {

         }
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Directory contents of <%= Context.Request.Path %></title>
        <link rel="stylesheet" href=".style.css">
        <script src=".sorttable.js"></script>

    </head>
    <body>
        <h2><%= Context.Request.Path %> <asp:HyperLink runat="server" id="NavigateUpLink">[..]</asp:HyperLink></h2>
        <p>
        <a href="?sortby=name">sort by name</a>/<a href="?sortby=namerev">-</a> |
        <a href="?sortby=date">sort by date</a>/<a href="?sortby=daterev">-</a> |
        <a href="?sortby=size">sort by size</a>/<a href="?sortby=sizerev">-</a>        
        </p>
        <form runat="server">
            
            <asp:DataList id="DirectoryListing" runat="server" OnSelectedIndexChanged="DirectoryListing_SelectedIndexChanged">
                <HeaderTemplate>
        <tr>
          <th>Filename</th>
          <th>Type</th>
          <th>Size <small>(bytes)</small></th>
          <th>Date Modified</th>
        </tr>
      </HeaderTemplate>
                <ItemTemplate>
                  <tr class='$class'>
                        <td><a href='./$namehref'>$name</a></td>
                        <td><a href='./$namehref'>$extn</a></td>
                        <td><a href='./$namehref'>$size</a></td>
                        <td sorttable_customkey='$timekey'><a href='./$namehref'>$modtime</a></td>
                  </tr>
                    <a href="<%# ((DirectoryListingEntry)Container.DataItem).VirtualPath  %>"><%# ((DirectoryListingEntry)Container.DataItem).Filename %></a>
                    &nbsp<%# GetFileSizeString(((DirectoryListingEntry)Container.DataItem).FileSystemInfo) %>
                </ItemTemplate>
            </asp:DataList>
            <hr />
            <p>
                <asp:Label runat="Server" id="FileCount" />
            </p>
        </form>
    </body>
</html>