<template>
  <div>
    <div id="topicon">
      <div class="window-full circularButtonView property tags circularButtonView--default circularButtonView--onWhiteBackground circularButtonView--active pull-right"
        tabindex="410" style="margin-top: 2px;">
        <span id="close" class="destroy circularButtonView-label" @click="CLOSE_DIV(todoObject)">
          <i class="fa fa-close"></i>
        </span>
      </div>
      <div class="window-full circularButtonView property tags circularButtonView--default circularButtonView--onWhiteBackground circularButtonView--active pull-right"
        style="margin-top: 2px;">
        <span class="circularButtonView-label" @click="pinit(todoObject)">
          <img class="init" v-if="todoObject.isPinned" src="../assets/unpin.png" style="width:20px; height:20px;"></img>
          <img class="init" v-else src="../assets/pin.png" style="width:16px; height:16px; margin-bottom:2px;"></img>
        </span>
      </div>
      <div class="window-full circularButtonView property tags circularButtonView--default circularButtonView--onWhiteBackground circularButtonView--active pull-right"
        tabindex="410" @click="openfullwinodw(todoObject.level)" style="margin-top: 2px; ">
        <span class="circularButtonView-label">
          <i class="fa fa-expand" aria-hidden="true"></i>
        </span>
      </div>
    </div>
    <div :id="id" class="right_pannel" style="display: grid;">
      <Alert v-if="todoObject.isDelete" class="right-top-alert" type="error">
        <span slot="desc">
          <span class="deleteIcon"><Icon type="android-delete" ></Icon></span>
          <span class="TaskUndeleteBanner-message">This task is deleted.</span>
          <a class="Button Button--small Button--secondary TaskUndeleteBanner-undeleteButton" @click="undelete(todoObject)">Undelete</a>
          <a class="Button Button--small Button--primary TaskUndeleteBanner-permadeleteButton" data-toggle="modal" :data-target="'.'+todoObject.id">Delete Permanently</a>
        </span>
      </Alert>
      <div class="tab-pannel">
          <component :is="currentView" 
            :id="id" 
            :taskId="todoObject.id" 
            :historyLog="historyLog" 
            :isDeleteAttachment="chkAttachment" 
            :filteredTodo="todoObject" 
            v-if="!$store.state.deleteItemsSelected && id !== 'rightTaskTypes' && id !== 'rightTaskState'" 
            :pholder="pholder" 
            :filtered-todos="taskById"
            :commentTaskId="todoObject.id">
          </component>
        </div>
        <div class="nav_bottom">
          <div class="navbar-bottom" id="myNavbar">
            <a href="javascript:void(0)" id="#subtask" v-bind:class="selectedMenuIndex==0?activeClass:''" class="nav-tab" @click="subTaskShow">
              <Tooltip content="Task" placement="top-start">
                <i class="nav-icon ion-navicon-round" style="font-size:20px"></i>
              </Tooltip>
            </a>
             <!-- Assign task to user menu item -->
            <div class="assing-to-menu">
                      <span style="float:left;margin-top:-3px">
                        <div v-if="getUserName()">
                          <avatar v-if="imageURlProfilePic" :username="getUserName()" :size='30' :src='imageURlProfilePic'></avatar>
                          <avatar v-else :username="getUserName()" color='#fff' :size='30'></avatar>
                        </div>
                      </span>
                      <Row>
                            <Col span="2" style="padding-right:10px">
                                <Select  not-found-text="No user found" placeholder="user"  placement="top" v-model="selectedUser" @on-change="userListClick" filterable  style="width:180px;z-index:99999">
                                      <Option style="margin:5px"  v-for="user in getUserList"  :label="getListUserName(user.email)" :value="user._id" :key="user._id">
                                          <span style="float:left;margin-right:10px;margin-top:-8px;width: 30px; height: 30px; border-radius: 50%; text-align: center; vertical-align: middle;background:#ccc">
                                            <avatar v-if="user.image_url" :username="user.email?user.email:'n/a'" :size='30' :src='checkProfilePicUrl(user.image_url)'></avatar>
                                            <avatar v-else color="white" :username="user.email?user.email:'n/a'"  :size='30'></avatar>
                                          </span>
                                          {{getListUserName(user.email)}}
                                      </Option>
                                </Select>
                            </col>
                      </Row>                                
            </div>
            <!-- Task due date menu item -->
             <div class="due-date">
               <DatePicker size="small" placement="top" type="date"
                           :value="todoObject.dueDate"
                           @on-change="dueDateClick"
                           format="dd MMM yyyy"
                           placeholder="Due date" style="width: 200px">
               </DatePicker>                             
            </div> 
            <!-- History -->
            <a href="javascript:void(0)"  v-bind:class="selectedMenuIndex==1?activeClass:''" class="nav-tab" @click="historyShow">
              <Tooltip content="History" placement="top-start">
                <i class="nav-icon fa fa-history" aria-hidden="true" style="font-size:20px"></i>
              </Tooltip>
            </a>
            <a href="javascript:void(0)" v-bind:class="selectedMenuIndex==2?activeClass:''" class="nav-tab" @click="attachmentShow">
              <Tooltip content="Attachments" placement="top-start">
                <i class="nav-icon fa fa-paperclip" aria-hidden="true" style="font-size:20px"></i>
              </Tooltip>
            </a>
            <a href="javascript:void(0)" v-bind:class="selectedMenuIndex==3?activeClass:''" class="nav-tab" @click="tagsShow">
              <Tooltip content="Tags" placement="top-start">
                <i class="nav-icon fa fa-tags" aria-hidden="true" style="font-size:20px"></i>
              </Tooltip>
            </a>
            <a href="javascript:void(0)" v-bind:class="selectedMenuIndex==4?activeClass:''" class="nav-tab" @click="commentsShow">
              <Tooltip content="Comments" placement="top-start">
                <i class="nav-icon fa fa-comments" aria-hidden="true" style="font-size:20px"></i>
              </Tooltip>
            </a>
            <div class="option">
              <Dropdown @on-click="moreActionMenuClick" trigger="click" placement="top">
                <a href="javascript:void(0)" @click="handleOpen" class="option-menu">
                  <i class="glyphicon glyphicon-option-horizontal" aria-hidden="true" style="font-size:22px"></i>
                </a>
                <DropdownMenu  slot="list">
                  <DropdownItem name="1">Estimated Hours</DropdownItem>
                  <DropdownItem name="2">Task Priority</DropdownItem>
                  <DropdownItem name="3">Copy Task URL</DropdownItem>
                  <DropdownItem name="4">Delete Task</DropdownItem>
                </DropdownMenu>
              </Dropdown>
            </div>
          </div>
          <div class="tab-container">
          </div>
      </div>
    </div>
    <div :class="todoObject.id" class="modal fade" role="dialog" aria-labelledby="myModalLabel2" style="display: none;">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
            <h4 class="modal-title" id="myModalLabel2">Permanently Delete {{todoObject.taskName}}</h4>
          </div>
          <div class="modal-body">
            This will permanently delete the task and associated subtasks. These items will no longer be accessible to you or anyone
            else. This action is irreversible.
          </div>
          <div class="modal-footer">
            <a class="Button Button--small Button--secondary TaskUndeleteBanner-undeleteButton" data-dismiss="modal">Close</a>
            <a class="Button Button--small Button--secondary TaskUndeleteBanner-undeleteButton" data-dismiss="modal" @click="deletePermently">Delete</a>
          </div>
        </div>
      </div>
    </div>
    <estimated-hours :showModal="estimated_time" :closeAction="closeDialog" :filteredTodo="todoObject"></estimated-hours>
    <task-priority :showModal="task_priority" :closeAction="closeDialog" :filteredTodo="todoObject"></task-priority>
  </div>
</template>
<script>
/* eslint-disable*/
import Vue from "vue";
import MainLeftSection from "./MainLeftSection.vue";
import TextDescription from "./TextDescription.vue";
import SubComment from "./SubComment.vue";
import HistoryLog from "./HistoryLog.vue";
import RightToolbar from "./RightToolbar.vue";
import Attachments from "./Attachments.vue";
import StoryFeed from "./StoryFeed.vue";
import Statuses from "./Statuses.vue";
import * as services from "../services";
import Tags from "./Tags.vue";
import SubTask from "./SubTask.vue";
import { mapMutations, mapGetters } from "vuex";
import iView from "iview";
import "iview/dist/styles/iview.css";
import CmnFunc from "./CommonFunc.js";
import * as Constant from "./Constants.js";
import AsyncComputed from "vue-async-computed";
import Avatar from "vue-avatar/dist/Avatar";
import Datepicker from "vuejs-datepicker";
import moment from "moment";
import EstimatedHours from './EstimatedHours.vue'
import TaskPriority from './TaskPriority.vue'
Vue.use(AsyncComputed);
Vue.filter("formatDate", function(value) {
  if (value) {
    return moment(String(value)).format("MMM DD");
  }
});

Vue.use(AsyncComputed);
export default {
  props: ["pholder", "todoObject", "id"],
  data: function() {
    return {
      todolistSubTasks: [],
      createCommentBox: true,
      readCommentBox: true,
      historyLog: [],
      isDelete: false,
      chkAttachment: false,
      attchmentReadPerm: false,
      isCreatePermission: false,
      isTagReadPermission: false,
      isTabContainerShow: false,
      currentView: SubTask,
      activeClass: "active",
      selectedMenuIndex: 0,
      modal_loading: false,
      topMargin: 20, // Top margin of sub task panel
      isDeleteActive: false, // Hide soft delete dialog
      imageURlProfilePic: "",
      model8: "",
      selectedUser: this.todoObject.assigned_to,
      previousUser: this.todoObject.assigned_to,
      userObj: "", // selected user object
      selectedUser: '',
      estimated_time: false,
      task_priority: false,
    };
  },
  created: function() {
    this.manageAttachmentCreatePermission();
    this.tagReadPermission();
    this.tagNewPermission();
  },
  methods: {
    ...mapMutations(["CLOSE_DIV"]),
    undelete: function() {
      this.$store.dispatch("undelete", this.todoObject);
    },
    moreActionMenuClick: function(val) {
      // Show Estimated Hour val=1
      if (val == 1){
        this.estimated_time = true
      }
      // Show Task Priority val=2
      else if(val == 2){
        this.task_priority = true
      }
       // Show copy Url val=3
      else if (val == 3) {
        var $temp = $("<input>");
        $("body").append($temp);
        var url = process.env.COPY_URL_PATH + "/navbar/task/" + (this.todoObject.level + 1) + "/" + this.todoObject.id
        $temp.val(url).select();
        document.execCommand("copy");
        $temp.remove();
      }
      // Show delete dialog val=4
      else if (val == 4) {
        this.$store.dispatch("delete_Todo", this.todoObject);
      }
    },
    closeDialog() {
      this.estimated_time = false
      this.task_priority = false
    },
    deletePermently: function() {
      this.$store.dispatch("deletePermently", this.todoObject);
    },
    getListValue: function(user) {
      if (user.email) {
        return user.email;
      } else {
        return "n/a";
      }
    },
    getListUserName: function(userName) {
      if (userName) {
        return userName;
      } else {
        return "n/a";
      }
    },
    onUserClick: function(user) {
      this.userObj = user;
      if (user.email) {
        return user.email;
      } else {
        return "n/a";
      }
    },
    userClick: function(user) {
      console.log("user detail call");
    },
    async onReadComment(id, level, created_by, typeId) {
      let permisionResult = await CmnFunc.checkActionPermision(
        this,
        typeId,
        Constant.USER_ACTION.COMMENT,
        Constant.PERMISSION_ACTION.READ
      );
      console.log("permisionResult Read Comment-->", permisionResult);
      if (!permisionResult && id != -1) {
        this.readCommentBox = false;
      } else {
        this.readCommentBox = true;
      }
    },
    async onCreateComment(id, level, created_by, typeId) {
      let permisionResult = await CmnFunc.checkActionPermision(
        this,
        typeId,
        Constant.USER_ACTION.COMMENT,
        Constant.PERMISSION_ACTION.CREATE
      );
      console.log("permisionResult Create Comment-->", permisionResult);
      if (!permisionResult && id != -1) {
        this.createCommentBox = false;
      } else {
        this.createCommentBox = true;
      }
    },
    userDetail(deletedTasks) {
      deletedTasks.forEach(function(c) {
        let userId = c.assigned_to;
        let userIndex = _.findIndex(this.$store.state.arrAllUsers, function(m) {
          return m._id === userId;
        });
        if (userIndex < 0) {
        } else {
          (c.image_url = this.$store.state.arrAllUsers[userIndex].image_url),
            (c.email = this.$store.state.arrAllUsers[userIndex].email);
        }
      }, this);
    },
    async manageAttachmentDeletePermission() {
      this.chkAttachment = await CmnFunc.checkActionPermision(
        this,
        this.todoObject.type_id,
        Constant.USER_ACTION.ATTACHEMENT,
        Constant.PERMISSION_ACTION.DELETE,
        "attachment"
      );
    },
    async manageAttachmentReadPermission() {
      return await CmnFunc.checkActionPermision(
        this,
        this.todoObject.type_id,
        Constant.USER_ACTION.ATTACHEMENT,
        Constant.PERMISSION_ACTION.READ,
        "attachment"
      );
    },
    manageAttachmentCreatePermission: async function() {
      this.isCreatePermission = await CmnFunc.checkActionPermision(
        this,
        this.todoObject.type_id,
        Constant.USER_ACTION.ATTACHEMENT,
        Constant.PERMISSION_ACTION.CREATE,
        "attachment"
      );
    },
    checkAttachmentExistance() {
      let attachmentArray = _.find(this.$store.state.arrAttachment, [
        "task_id",
        this.todoObject.id
      ]);
      let isAttachmentExist = false;
      if (attachmentArray) {
        isAttachmentExist = true;
      } else {
        isAttachmentExist = false;
      }
      return isAttachmentExist;
    },
    async tagReadPermission() {
      this.isTagReadPermission = await CmnFunc.checkActionPermision(
        this,
        this.todoObject.type_id,
        Constant.USER_ACTION.TAG,
        Constant.PERMISSION_ACTION.READ
      );
      console.log("Tag read permission:", this.isTagReadPermission);
    },
    async tagNewPermission() {
      this.isTagReadPermission = await CmnFunc.checkActionPermision(
        this,
        this.todoObject.type_id,
        Constant.USER_ACTION.TAG,
        Constant.PERMISSION_ACTION.CREATE
      );
      console.log("Tag create permission:", this.isTagReadPermission);
    },
    subTaskShow() {
      this.selectedMenuIndex = 0;
      this.currentView = SubTask;
    },
    attachmentShow() {
      $(".nav").removeClass("hidden");
      this.selectedMenuIndex = 2;
      this.currentView = Attachments;
    },
    tagsShow() {
      this.selectedMenuIndex = 3;
      this.currentView = Tags;
    },
    historyShow() {
      this.selectedMenuIndex = 1;
      this.currentView = HistoryLog;
    },
    commentsShow() {
      this.selectedMenuIndex = 4;
      this.currentView = SubComment;
    },
    assignToShow() {
      this.selectedMenuIndex = 5;
    },
    handleOpen() {
      this.selectedMenuIndex = 5;
      $(".nav").addClass("hidden");
    },
    openfullwinodw: function(ind) {
      console.log("Openfullwindow called====");
      $(".window-full.circularButtonView")
        .find(".fa")
        .toggleClass("fa-compress");
      $(".window-full.circularButtonView")
        .parents(".right_pane_container #right_pane #" + ind)
        .toggleClass("open");
    },
    pinit(filteredTodo) {
      console.log("TODO Object", filteredTodo);
      if (
        _.find(this.$store.state.todolist, ["id", filteredTodo.id]) &&
        !_.find(this.$store.state.todolist, ["id", filteredTodo.id]).isPinned
      ) {
        console.log("pinnned true");
        _.find(this.$store.state.todolist, [
          "id",
          filteredTodo.id
        ]).isPinned = true;
      } else {
        console.log("pinnned false");
        _.find(this.$store.state.todolist, [
          "id",
          filteredTodo.id
        ]).isPinned = false;
      }
    },
    async setAssignUser(userId) {
      console.log("user id -->", userId);
      var user = _.find(this.$store.state.arrAllUsers, ["_id", userId]);
      console.log("Selected User setAssignUser method:", user);
      if (user) {
        this.$store.dispatch("editTaskName", {
          todo: this.todoObject,
          assigned_by: this.$store.state.userObject._id,
          assigned_to: user._id
        });
      }
    },
    getAssignedUserName() {
      var user = this.getAssignedUserObj();
      return user.email ? this.getName(user.email) : "";
    },
    getName(name) {
      var str = name;
      var n = str.indexOf("@");
      var res = str.substr(0, n);
      return res;
    },
    getAssignedUserObj(assignUserId) {
      var objUser;
      if (this.todoObject.assigned_to === this.$store.state.userObject._id) {
        objUser = this.$store.state.userObject;
      } else {
        objUser = _.find(this.$store.state.arrAllUsers, [
          "_id",
          assignUserId
        ]);
      }
      return objUser;
    },
    getUserName() {
      var user = this.getAssignedUserObj(this.todoObject.assigned_to)
      if (!user) {
        return;
      }
      this.selectedUser = user._id;
      this.previousUser=user._id;
      if (user.image_url) {
        this.imageURlProfilePic = user.image_url;
        return "";
      }
      this.imageURlProfilePic = "";
      return user.email;
    },
    capitalizeLetters(name) {
      var str = "null";
      if (name != null) {
        str = name;
      }
      // else if(name.fullname != null){
      //   console.log('Name', name.fullname)
      //   str = name.fullname
      // }
      // var str = name.email
      var firstLetters = str.substr(0, 2);
      return firstLetters.toUpperCase();
    },
    checkProfilePicUrl(url) {
      if (url) {
        return url;
      } else {
        return "";
      }
    },
    dueDateClick(dateTo) {
      var selectedDate = moment(dateTo, "YYYY-MM-DD").format("MMM DD");
      this.$store.dispatch("editTaskName", {
        todo: this.todoObject,
        selectedDate: dateTo
      });
    },
    /**
    * Selected user from assign user list
    */
    userListClick: function(user_id){
      if(this.selectedUser!==this.previousUser)
         this.setAssignUser(user_id)
    }
  },
  watch: {
    // whenever question changes, this function will run
    todolistSubTasks: function(newQuestion) {},
    todoObject: function() {
      console.log("Right Section Log history", this.todoObject);
      this.$store.dispatch("findHistoryLog", this.todoObject.id);
    },
    todoObject: function(todo) {
      this.previousUser=this.selectedUser;
      this.selectedUser = todo.assigned_to;
    }
  },
  computed: {
    ...mapGetters({
      todoById: "getTodoById",
      typeStateList: "getTask_types_state",
      getUserList: "getAllUserList"
    }),
    taskById() {
      this.onReadComment(
        this.todoObject.id,
        this.todoObject.level,
        this.todoObject.created_by,
        this.todoObject.type_id
      );
      this.onCreateComment(
        this.todoObject.id,
        this.todoObject.level,
        this.todoObject.created_by,
        this.todoObject.type_id
      );
      let taskArray = this.todoById(this.todoObject.id, this.todoObject.level);
      taskArray.push({
        id: "-1",
        parentId: this.todoObject.id,
        taskName: "",
        taskDesc: "",
        level: this.todoObject.level + 1,
        index: taskArray.length,
        completed: false,
        dueDate: "",
        createdAt: new Date().toJSON(),
        updatedAt: new Date().toJSON(),
        project_id: this.$store.state.currentProjectId
      });
      this.todolistSubTasks = taskArray;
      this.userDetail(this.todolistSubTasks);
      return taskArray;
    }
  },
  asyncComputed: {
    async showAttachment() {
      this.manageAttachmentDeletePermission();
      if (this.isCreatePermission) {
        return this.checkAttachmentExistance();
      }
      //check attachment for only  read permission.
      let isReadPermission = await this.manageAttachmentReadPermission();
      if (isReadPermission) {
        console.log("inside read permission");
        //check whether attachment array has value or not
        return this.checkAttachmentExistance();
      } else {
        console.log("read permission false:", isReadPermission);
        //this.attchmentReadPerm = false
        return false;
      }
      // return this.$store.state.arrAttachment.length > 0 ? true : false
    }
  },
  components: {
    // RightFooter,
    MainLeftSection,
    TextDescription,
    RightToolbar,
    Attachments,
    StoryFeed,
    Tags,
    Statuses,
    HistoryLog,
    SubComment,
    Avatar,
    Datepicker,
    // Comment,
    EstimatedHours,
    TaskPriority
  }
};
</script>
<style scoped>
.navbar-bottom {
  overflow: hidden;
  background-color: #333;
  bottom: 0;
  width: 100%;
}
.navbar-bottom a {
  float: left;
  display: block;
  color: white;
  text-align: center;
  padding: 6px 26px;
  text-decoration: none;
}
.navbar-bottom div {
  margin-top: 1px;
}
.navbar-bottom a.active {
  /*background-color: rgba(63, 81, 181, 0.48);*/
  background-color: #999999;
  color: white;
}
.navbar-bottom:hover a.active {
  /*background-color: rgba(63, 81, 181, 0.90);*/
  background-color: #999999;
  color: white;
}
.navbar-bottom .icon {
  display: none;
}
.nav-icon {
  font-size: x-large;
}
.nav-title {
  font-size: small;
}
.tab-container {
  display: none;
}
.tab-container-active {
  display: block;
  width: 100%;
  background: white;
  /* height: 510px; */
}
div.right_pannel {
  width: 100%;
  height: 100%;
}
.tab-pannel {
  /* overflow-y: scroll; */
  height: 95%;
  /* position: absolute; */
  width: 100%;
  overflow-x: hidden;
}
.nav_bottom {
  position: absolute;
  bottom: 0;
  width: 100%;
  /* height of the bottom tab bar */
  height: 36px;
  z-index: 999;
}
.nav-sub-bottom {
  height: 320px;
}
a.option-menu.glyphicon.glyphicon-option-horizontal {
  float: right;
}
.right_pane_container #right_pane {
  width: 100%;
  height: 100%;
  overflow: hidden;
}
.option-menu {
  float: right;
}
.right-top-alert {
  top: 10px;
}
.ivu-alert-error {
  border: 1px solid #d7c5c7;
  background-color: #ffedef;
}
.deleteIcon {
  font-size: 2.5em;
  margin-right: 10px;
  color: #ed3f14;
}
.navbar-bottom .assing-to-menu {
  padding: 5px;
  border-radius: 30px;
  background: #fff;
  float: left;
  height: 34px;
  width: 117px;
}
.navbar-bottom .assing-to-menu:hover {
  background: #fff;
  -webkit-box-shadow: 0 0 0 3px #02CEFF;
  height: 32px;
}
.navbar-bottom .due-date {
  padding: 5px;
  border-radius: 30px;
  background: #fff;
  float: left;
  margin-top:2px;
  height: 33px;
  width: 120px;
  margin-left:2px;
}
.navbar-bottom .due-date:hover {
  background: #fff;
  -webkit-box-shadow: 0 0 0 3px #02CEFF;
  height: 32px;
}

</style>

